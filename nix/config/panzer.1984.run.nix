{ config, lib, pkgs, ... }:
with builtins; {
  imports = [ ../modules ];

  boot = {
    initrd = {
      availableKernelModules = [
        "aes_x86_64"
        "aesni_intel"
        "ahci"
        "cryptd"
        "dm_multipath"
        "dm_persistent_data"
        "ehci_pci"
        "sd_mod"
        "sdhci_pci"
        "sr_mod"
        "usb_storage"
        "xhci_pci"
      ];

      extraUtilsCommands = ''
        copy_bin_and_libs ${pkgs.thin-provisioning-tools}/bin/pdata_tools
        copy_bin_and_libs ${pkgs.thin-provisioning-tools}/bin/thin_check
      ''; # hack to boot on thin pool

      kernelModules = [ "dm_thin_pool" "dm-snapshot" ]; # hack to boot on thin pool

      luks.devices = [
        {
          name = "luks-ssd";
          device = "/dev/sdb2";
          preLVM = true;
          allowDiscards = true;
        }
      ];

      preLVMCommands = ''
        mkdir -p /etc/lvm
        echo "global/thin_check_executable = \"$(which thin_check)\"" >> /etc/lvm/lvm.conf
      ''; # hack to boot on thin pool
    };

    kernelModules = [ "dm_thin_pool" "kvm-intel" ];

    kernelParams = [ "quiet" "splash" "resume=/dev/mapper/panzer--vg-swap" ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  environment.etc = {
    "lvm/lvm.conf".text = ''
      activation {
        activation_mode = "partial"
      }
      devices {
        issue_discards = 1
      }
    '';
  };

  environment.systemPackages = with pkgs;
    [
      thin-provisioning-tools # required to boot on the encrypted lvm thin pool
    ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/dc4bc91d-f0b2-4975-8be2-5d57494754c7";
      fsType = "ext4";
      options = [ "relatime" "discard" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/1f0402b3-871e-4a6a-be68-c37f799afced";
      fsType = "ext4";
      options = [ "relatime" "discard" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0042-76F2";
      fsType = "vfat";
    };
  };

  hardware = {
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;
    opengl.driSupport32Bit = true;
  };

  local = {
    hardware.machine = "thinkpad-T430s";
    roles.workstation.enable = true;
    users.setupUsers = [ "sk" ];
  };

  networking = {
    hostId = "af63d82e";
    hostName = "panzer";
    search = [ "1984.run" ];
  };

  nix.maxJobs = lib.mkDefault 4;

  services = {
    fstrim.enable = true;
    tlp = {
      enable = true;
      extraConfig = ''
        TLP_DEFAULT_MODE=BAT
        CPU_HWP_ON_BAT=power
        CPU_SCALING_GOVERNOR_ON_BAT=powersave
        DISK_IOSCHED="noop cfq"
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE="bluetooth wwan"
        DEVICES_TO_DISABLE_ON_LAN_CONNECT="wifi wwan"
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT="wifi wwan"
        WOL_DISABLE=Y
      '';
    };
    zerotierone = {
      enable = true;
      joinNetworks = [ "1c33c1ced08df9ac" "0cccb752f7043dce" ];
    };
  };

  swapDevices = [ { device = "/dev/mapper/panzer--vg-swap"; } ];
}
