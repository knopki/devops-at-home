{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  self,
  ...
}:
let
  inherit (lib) mkDefault;
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
  imports =
    with inputs.nixos-hardware.nixosModules;
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      common-cpu-intel-cpu-only
      common-gpu-intel
      # common-gpu-nvidia-nonprime
      common-gpu-nvidia-disable
      common-pc-ssd
    ]
    ++ (with self.modules.nixos; [ mixin-systemd-boot ]);

  boot = {
    extraModprobeConfig = ''
      options snd_hda_intel index=0 model=alienware enable_msi=1 position_fix=0
      options dell-smm-hwmon force=1
      options i8k force=1
      options i915 error_capture=1 mitigations=off
      options zfs zfs_bclone_enabled=1
    '';
    extraModulePackages = with config.boot.kernelPackages; [ amneziawg ];
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
      };
    };

    kernelModules = [
      "dell-smm-hwmod"
      "kvm-intel"
    ];
    kernelParams = [
      "resume=${swapPartName}"
      "acpiphp.disable=1"
      "pcie_aspm.policy=powersave"
    ];

    loader = {
      # efi.canTouchEfiVariables = false;
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
    systemPackages = with pkgs; [
      intel-gpu-tools
      opensc
      softhsm
    ];
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
  };

  hardware = {
    graphics = {
      enable = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        libvdpau-va-gl
        vaapiIntel
        vaapiVdpau
      ];
    };
    # nvidia = {
    #   modesetting.enable = true;
    #   prime = {
    #     intelBusId = "PCI:0:2:0";
    #     nvidiaBusId = "PCI:1:0:0";
    #     offload.enable = false;
    #     sync.enable = true;
    #   };
    #   powerManagement = {
    #     enable = false;
    #     finegrained = false;
    #   };
    # };
  };

  nix.settings.max-jobs = mkDefault 8;
  nixpkgs.hostPlatform = "x86_64-linux";

  services = {
    autorandr =
      let
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
      in
      {
        enable = true;
        profiles."mobile" = {
          fingerprint = {
            eDP-1 = eDPEDID;
          };
          config = {
            eDP-1 = eDPconf;
          };
        };
        profiles."mobile-sync" = {
          fingerprint = {
            eDP-1-1 = eDPEDID;
          };
          config = {
            eDP-1-1 = eDPconf;
          };
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
      extraRules = ''
        # Raspberry Pi Pico
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", MODE="0660", TAG+="uaccess", SYMLINK+="pico%n"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0009", MODE="0660", TAG+="uaccess", SYMLINK+="pico%n"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="000a", MODE="0660", TAG+="uaccess", SYMLINK+="pico%n"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="000f", MODE="0660", TAG+="uaccess", SYMLINK+="pico%n"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2e9a", ATTRS{idProduct}=="cafe", MODE="0660", TAG+="uaccess", SYMLINK+="pico%n"
      '';
    };

    pcscd = {
      enable = true;
      plugins = [ pkgs.ccid ];
    };

    xserver = {
      dpi = 96;
      # videoDrivers = ["nvidia"];
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
      priority = 1;
    }
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  zramSwap = {
    enable = true;
    algorithm = "lz4";
    priority = 100;
    memoryPercent = 50;
    swapDevices = 1;
  };
}
