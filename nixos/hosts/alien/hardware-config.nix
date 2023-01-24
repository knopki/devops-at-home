{ config, lib, pkgs, modulesPath, inputs, ... }:
let
  inherit (lib) mkDefault writeText;
  luksCommon = {
    preLVM = true;
    allowDiscards = true;
    keyFile = "/dev/disk/by-id/usb-USB_Flash_Disk_CCYYMMDDHHmmSS71FZGI-0:0";
    keyFileOffset = 512 * 8;
    keyFileSize = 512 * 8;
    fallbackToPassword = true;
  };
  swapPartName = "/dev/nvme-vg/swap";
in
{
  imports = with inputs.nixos-hardware.nixosModules; [
    (modulesPath + "/installer/scan/not-detected.nix")
    common-cpu-intel
    common-gpu-nvidia
    common-pc-ssd
  ];

  boot = {
    extraModprobeConfig = ''
      options snd_hda_intel index=0 model=alienware enable_msi=1 position_fix=0
      options dell-smm-hwmon force=1
      options i8k force=1
      options i915 error_capture=1 mitigations=off
    '';
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "aesni_intel"
        "ahci"
        "cryptd"
        "kvm-intel"
        "nvme"
        "rtsx_pci_sdmmc"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "sd_mod"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [ "dm-snapshot" ];

      luks.devices = {
        "luks-nvme" = luksCommon // {
          device = "/dev/disk/by-uuid/b7bb1cfc-414b-4806-b7b3-ff80df7a48d5";
        };
        "luks-sata" = luksCommon // {
          device = "/dev/disk/by-uuid/c594a74b-464d-49eb-a2de-70d08b75c328";
        };
      };
    };

    kernelModules = [ "dell-smm-hwmod" "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "resume=${swapPartName}"
      "acpiphp.disable=1"
      "pcie_aspm.policy=powersave"
    ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
    };
  };

  environment = {
    etc = {
      "lvm/lvm.conf".text = ''
        devices {
          issue_discards = 1
        }
      '';
    };
    systemPackages = with pkgs; [ intel-gpu-tools ];
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/6964-B539";
      fsType = "vfat";
    };
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
  };

  hardware = {
    fancontrol = {
      enable = true;
      config = ''
        INTERVAL=2
        DEVPATH=hwmon6=devices/platform/dell_smm_hwmon
        DEVNAME=hwmon6=dell_smm
        # pwr3 connected to temp2 (gpu)
        # pwr1 connected to temp1 (cpu)
        FCTEMPS=hwmon6/pwm3=hwmon6/temp2_input hwmon6/pwm1=hwmon6/temp1_input
        FCFANS=hwmon6/pwm3=hwmon6/fan3_input hwmon6/pwm1=hwmon6/fan1_input
        MINTEMP=hwmon6/pwm3=38 hwmon6/pwm1=38
        MAXTEMP=hwmon6/pwm3=60 hwmon6/pwm1=60
        MINSTART=hwmon6/pwm3=75 hwmon6/pwm1=75
        MINSTOP=hwmon6/pwm3=60 hwmon6/pwm1=60
        MINPWM=hwmon6/pwm3=0 hwmon6/pwm1=0
        MAXPWM=hwmon6/pwm3=210 hwmon6/pwm1=210
        AVERAGE=hwmon6/pwm3=5 hwmon6/pwm1=5
      '';
    };
    opengl = {
      enable = true;
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
        offload.enable = true;
      };
      powerManagement = { enable = true; finegrained = true; };
    };
  };

  nix.settings.max-jobs = mkDefault 8;
  nixpkgs.system = "x86_64-linux";

  services = {
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

    xserver.videoDrivers = [ "nvidia" ];
  };

  swapDevices = [{ device = swapPartName; discardPolicy = "both"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  zramSwap = { enable = true; swapDevices = 1; };
}
