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
          device = "/dev/disk/by-uuid/d3600e29-69a8-4aeb-a604-e34ac1f0e954";
          preLVM = true;
          allowDiscards = true;
          keyFile = "/dev/disk/by-id/usb-General_USB_Flash_Disk_04QEWH3O9LW8DPIK-0:0";
          keyFileOffset = 12;
          keyFileSize = 4096;
          fallbackToPassword = true;
        }
      ];
    };

    kernelModules = [ "kvm-intel" ];

    kernelParams = [
      "quiet"
      "splash"
      "resume=/dev/disk/by-uuid/3eef3ff7-958f-474a-ac90-ae6d16b349ee"
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
      device = "/dev/disk/by-uuid/7d0ea5b4-22ce-4727-9781-78a98f781ca6";
      fsType = "ext4";
      options = [ "relatime" ];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/e67c2655-2738-40d5-a566-1756654225d9";
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

  swapDevices = [ { device = "/dev/disk/by-uuid/3eef3ff7-958f-474a-ac90-ae6d16b349ee"; } ];
}
