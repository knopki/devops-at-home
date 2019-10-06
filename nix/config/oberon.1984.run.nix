{ config, lib, pkgs, ... }:
with builtins; {
  imports =
    [ ../modules <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot = {
    extraModprobeConfig = ''
      options i915 enable_guc=3
    '';
    extraModulePackages = [];
    initrd = {
      availableKernelModules =
        [
          "aes_x86_64"
          "aesni_intel"
          "ahci"
          "cryptd"
          "sd_mod"
          "usb_storage"
          "usbhid"
          "xhci_pci"
        ];

      kernelModules = [ "dm-snapshot" ];

      luks.devices = [
        {
          name = "luks-sata";
          device = "/dev/sda2";
          preLVM = true;
          allowDiscards = true;
        }
      ];
    };

    kernelModules = [ "kvm-intel" ];

    kernelParams = [
      "quiet"
      "splash"
      "resume=/dev/mapper/oberon-swap"
      "nohz_full=1-7"
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
      device = "/dev/mapper/oberon-root";
      fsType = "ext4";
      options = [ "relatime" ];
    };
    "/home" = {
      device = "/dev/mapper/oberon-home";
      fsType = "ext4";
      options = [ "relatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/6946-BBA2";
      fsType = "vfat";
    };
    "/srv/backups" = {
      device = "/dev/disk/by-uuid/31589793-bc0a-4313-ae5d-40f632a8666f";
      fsType = "ext4";
    };
  };

  hardware = {
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;
    opengl.driSupport32Bit = true;
  };

  local = {
    hardware.machine = "generic";
    roles.workstation.enable = true;
    services.azire-vpn = {
      enabled = true;
      ips = [ "10.10.5.91/19" "2a03:8600:1001:4000::55c/64" ];
      publicKey = "T28Qn5VFzT4wiwEPd7DscwcP3Rsmq23QcnjH1N5G/wc=";
    };
    users.setupUsers = [ "sk" ];
  };

  networking = {
    hostId = "a8b4f00d";
    hostName = "oberon";
    search = [ "1984.run" ];
  };

  nix.maxJobs = lib.mkDefault 4;

  services = {
    fstrim.enable = true;
    zerotierone = {
      enable = true;
      joinNetworks = [ "1c33c1ced08df9ac" "0cccb752f7043dce" ];
    };
  };

  swapDevices = [ { device = "/dev/mapper/oberon-swap"; } ];
}
