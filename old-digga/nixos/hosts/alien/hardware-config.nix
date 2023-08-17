{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}: let
  inherit (lib) mkDefault mkForce;
  luksCommon = {
    preLVM = true;
    allowDiscards = true;
    keyFile = "/dev/disk/by-id/usb-USB_Flash_Disk_CCYYMMDDHHmmSS71FZGI-0:0";
    keyFileOffset = 512 * 8;
    keyFileSize = 512 * 8;
    fallbackToPassword = true;
  };
  swapPartName = "/dev/nvme-vg/swap";
in {
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
    extraModulePackages = [];
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
      kernelModules = ["dm-snapshot"];

      luks.devices = {
        "luks-nvme" =
          luksCommon
          // {
            device = "/dev/disk/by-uuid/b7bb1cfc-414b-4806-b7b3-ff80df7a48d5";
          };
        "luks-sata" =
          luksCommon
          // {
            device = "/dev/disk/by-uuid/c594a74b-464d-49eb-a2de-70d08b75c328";
          };
      };
    };

    kernelModules = ["dell-smm-hwmod" "kvm-intel"];
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
    systemPackages = with pkgs; [intel-gpu-tools];
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/6964-B539";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-uuid/e384e984-2dbf-470d-82b2-7d994f4b4a7b";
      fsType = "ext4";
      options = ["relatime"];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/ce307698-b1ea-4ef1-b104-304275e71818";
      fsType = "ext4";
      options = ["relatime"];
    };
  };

  hardware = {
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
        offload.enable = false;
        sync.enable = true;
      };
      powerManagement = {
        enable = false;
        finegrained = false;
      };
    };
  };

  nix.settings.max-jobs = mkDefault 8;
  nixpkgs.hostPlatform = "x86_64-linux";

  services = {
    autorandr = let
      eDPEDID = "00ffffffffffff004c83484c0000000000190104952213780a32359557568e291f505400000001010101010101010101010101010101603980dc703840403020250058c21000001ae72d80dc703840403020250058c21000001a000000fe00344e44444a80313536484c0a20000000000000412196011000000a010a20200055";
      eDPconf = {
        enable = true;
        primary = true;
        crtc = 0;
        mode = "1920x1080";
        position = "0x0";
        rate = "60.00";
        dpi = 96;
      };
    in {
      enable = true;
      profiles."mobile" = {
        fingerprint = {eDP-1 = eDPEDID;};
        config = {eDP-1 = eDPconf;};
      };
      profiles."mobile-sync" = {
        fingerprint = {eDP-1-1 = eDPEDID;};
        config = {eDP-1-1 = eDPconf;};
        #hooks.postswitch."change-dpi" = ''
        #  echo "Xft.dpi: 144" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
        #'';
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
      dpi = 96;
      videoDrivers = ["nvidia"];
      # monitorSection = ''
      #   DisplaySize 338 190
      # '';
      # screenSection = ''
      #   Option "DPI" "144 x 144"
      # '';
    };
  };

  swapDevices = [
    {
      device = swapPartName;
      discardPolicy = "both";
    }
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  zramSwap = {
    enable = true;
    swapDevices = 1;
  };
}
