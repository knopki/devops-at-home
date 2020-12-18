{ modulesPath, lib, pkgs, self, inputs, ... }@args:
with lib;
let
  hwModules = inputs.nixos-hardware.nixosModules;
  luksCommon = {
    preLVM = true;
    allowDiscards = true;
    keyFile = "/dev/disk/by-id/usb-USB_Flash_Disk_CCYYMMDDHHmmSS71FZGI-0:0";
    keyFileOffset = 512 * 8;
    keyFileSize = 512 * 8;
    fallbackToPassword = true;
  };
  swapDevice = "/dev/mapper/nvme--vg-swap";
in
{
  imports = [
    hwModules.common-cpu-intel
    hwModules.common-gpu-nvidia
    hwModules.common-pc-laptop
    hwModules.common-pc-ssd
    ../profiles/workstation.nix
  ];

  boot = {
    extraModprobeConfig = ''
      options snd_hda_intel index=0 model=alienware enable_msi=1 position_fix=0
      options i8k force=1
      options i915 enable_fbc=1 enable_guc=3 enable_psr=1
    '';
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "usb_storage"
        "xhci_pci"
        # intel
        "aes_x86_64"
        "aesni_intel"
        "cryptd"
        # libvirt
        "kvm-intel"
      ];

      kernelModules = [ "dm-snapshot" ];

      luks.devices = {
        "luks-nvme" = (
          luksCommon // {
            device = "/dev/disk/by-uuid/b7bb1cfc-414b-4806-b7b3-ff80df7a48d5";
          }
        );
        "luks-sata" = (
          luksCommon // {
            device = "/dev/disk/by-uuid/c594a74b-464d-49eb-a2de-70d08b75c328";
          }
        );
      };
    };

    kernelParams = [
      "resume=${swapDevice}"
      "acpiphp.disable=1"
      "pcie_aspm.policy=powersave"
    ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  environment.etc = {
    "lvm/lvm.conf".text = ''
      devices {
        issue_discards = 1
      }
    '';
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/e384e984-2dbf-470d-82b2-7d994f4b4a7b";
      fsType = "ext4";
      options = [ "relatime" ];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/ce307698-b1ea-4ef1-b104-304275e71818";
      fsType = "ext4";
      options = [ "relatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/6964-B539";
      fsType = "vfat";
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        libvdpau-va-gl
        vaapiIntel
        vaapiVdpau
      ];
    };
    nvidia = {
      modesetting.enable = true;
      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      powerManagement.enable = true;
    };
  };


  knopki = {
    users = {
      root.enable = true;
      sk.enable = true;
    };
  };

  meta.machine = "alien";

  networking = {
    hostId = "ff0b9d65";
    hostName = "alien";
    hosts = {
      "127.0.0.84" = [
        "adminer.xod.loc"
        "api.xod.loc"
        "auth.xod.loc"
        "compile.xod.loc"
        "mail.xod.loc"
        "mqtt.xod.loc"
        "pm.xod.loc"
        "releases.xod.loc"
        "rethinkdb.xod.loc"
        "swagger-ui.xod.loc"
        "xod.loc"
      ];
    };
    search = [ "1984.run" ];
    firewall.allowedTCPPorts = [ 8080 ];
  };

  nix.maxJobs = lib.mkDefault 8;

  services = {
    logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend";
      extraConfig = ''
        InhibitDelayMaxSec=10
      '';
    };

    # broken: stuck at 800MHz
    thermald.enable = false;

    tlp = {
      settings = {
        TLP_ENABLE = "1";
        SOUND_POWER_SAVE_ON_BAT = "0";
        DISK_IOSCHED = "mq-deadline mq-deadline";
        INTEL_GPU_MIN_FREQ_ON_AC = "600";
        INTEL_GPU_MIN_FREQ_ON_BAT = "350";
        INTEL_GPU_MAX_FREQ_ON_AC = "1050";
        INTEL_GPU_MAX_FREQ_ON_BAT = "1050";
        INTEL_GPU_BOOST_FREQ_ON_AC = "1050";
        INTEL_GPU_BOOST_FREQ_ON_BAT = "1050";
        WOL_DISABLE = "Y";
        CPU_BOOST_ON_AC = "1";
        CPU_BOOST_ON_BAT = "0";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        DEVICES_TO_ENABLE_ON_STARTUP = "wwan";
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth";
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi";
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi";
      };
    };
    udev = {
      extraHwdb = ''
        # Alienware 15 R2 laptops
        evdev:atkbd:dmi:bvn*:bvr*:bd*:svnAlienware*:pnAlienware15R2:pvr*
          KEYBOARD_KEY_ba=switchvideomode # Fn+F8 CRT/LCD
          KEYBOARD_KEY_69=kbdillumtoggle  # Fn+F12 Alien FX
          KEYBOARD_KEY_91=f13             # left column X
          KEYBOARD_KEY_92=f14             # left column 1
          KEYBOARD_KEY_93=f15             # left column 2
          KEYBOARD_KEY_94=f16             # left column 3
          KEYBOARD_KEY_95=f17             # left column 4
          KEYBOARD_KEY_96=f18             # left column 5
      '';
    };
    # broken after bios upgraded 1.7.0 -> 1.11.0
    # undervolt = {
    #   enable = true;
    #   verbose = true;
    #   temp = 90;
    #   useTimer = true;
    #   coreOffset = -175;
    #   uncoreOffset = -???;
    # };
    xserver = {
      displayManager.gdm.nvidiaWayland = true;
    };
    zerotierone = {
      enable = true;
      joinNetworks = [ "1c33c1ced08df9ac" "0cccb752f7043dce" ];
    };
  };

  swapDevices = [{ device = swapDevice; }];

  system.stateVersion = "20.09";

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=6h
  '';
}
