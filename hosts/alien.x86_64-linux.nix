{ modulesPath, lib, pkgs, self, utils, ... }@args:
with lib;
let
  luksCommon = {
    preLVM = true;
    allowDiscards = true;
    keyFile = "/dev/disk/by-id/usb-USB_Flash_Disk_CCYYMMDDHHmmSS71FZGI-0:0";
    keyFileOffset = 512 * 8;
    keyFileSize = 512 * 8;
    fallbackToPassword = true;
  };
  swapDevice = "/dev/mapper/nvme--vg-swap";
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  imports = [
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
  environment.systemPackages = with pkgs; [ nvidia-offload ];

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
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        vaapiIntel
      ];
    };
    nvidia = {
      modesetting.enable = true;
      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        # sync.enable = true;
        offload.enable = true;
      };
      powerManagement.enable = true;
    };
  };


  knopki = {
    services.azire-vpn = {
      enabled = true;
      ips = [ "10.10.1.112/19" "2a03:8600:1001:4000::171/64" ];
      publicKey = "T28Qn5VFzT4wiwEPd7DscwcP3Rsmq23QcnjH1N5G/wc=";
      endpoint = "se1.wg.azirevpn.net:51820";
    };
    users = {
      root.enable = true;
      sk.enable = true;
    };
  };

  meta.machine = "alien";

  networking = {
    hostId = "ff0b9d65";
    hostName = "alien";
    search = [ "1984.run" ];
    firewall.allowedTCPPorts = [ 8080 ];
  };

  nix.maxJobs = lib.mkDefault 8;

  services = {
    fstrim.enable = true;
    logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend";
      extraConfig = ''
        InhibitDelayMaxSec=10
      '';
    };
    tlp = {
      enable = true;
      settings = {
        TLP_DEFAULT_MODE = "BAT";
        CPU_HWP_ON_BAT = "balance_power";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        DISK_IOSCHED = "noop cfq";
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wwan";
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi wwan";
        WOL_DISABLE = "Y";
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
    xserver = {
      displayManager.gdm.nvidiaWayland = true;
      videoDrivers = [ "nvidia" ];
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
