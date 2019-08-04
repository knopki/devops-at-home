{ config, lib, pkgs, ... }:
with builtins; {
  imports =
    [ ./modules <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot = {
    extraModprobeConfig = ''
      blacklist snd-intel8x0m
      options snd_hda_intel position_fix=1
      options i8k force=1
      options i915 enable_fbc=1 enable_guc=3 enable_psr=1
    '';
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules =
        [ "ahci" "nvme" "rtsx_pci_sdmmc" "sd_mod" "usb_storage" "xhci_pci" ];

      kernelModules = [ "kvm-intel" ];

      luks.devices = [
        {
          name = "luks-nvme";
          device = "/dev/nvme0n1p2";
          preLVM = true;
          allowDiscards = true;
        }
        {
          name = "luks-sata";
          device = "/dev/sda1";
          preLVM = true;
          allowDiscards = true;
        }
      ];
    };

    kernelParams = [
      "quiet"
      "splash"
      "resume=/dev/mapper/nvme--vg-swap"
      "acpiphp.disable=1"
      "nohz_full=1-7"
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
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;
    opengl.driSupport32Bit = true;
  };

  local = {
    hardware.machine = "alienware-15r2";
    roles.workstation.enable = true;
    services.azire-vpn = {
      enabled = true;
      ips = [ "10.10.16.213/19" "2a03:8600:1001:4000::10d6/64" ];
      publicKey = "T28Qn5VFzT4wiwEPd7DscwcP3Rsmq23QcnjH1N5G/wc=";
    };
    users.setupUsers = [ "sk" ];
  };

  networking = {
    hostId = "ff0b9d65";
    hostName = "alien";
    search = [ "1984.run" ];
  };

  nix.maxJobs = lib.mkDefault 8;

  services = {
    fstrim.enable = true;
    tlp = {
      enable = true;
      extraConfig = ''
        TLP_DEFAULT_MODE=BAT
        CPU_HWP_ON_BAT=balance_power
        CPU_SCALING_GOVERNOR_ON_BAT=powersave
        DISK_IOSCHED="noop cfq"
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE="bluetooth wwan"
        DEVICES_TO_DISABLE_ON_LAN_CONNECT="wifi wwan"
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT="wifi wwan"
      '';
    };
    zerotierone = {
      enable = true;
      joinNetworks = [ "1c33c1ced08df9ac" "0cccb752f7043dce" ];
    };
  };

  swapDevices = [{ device = "/dev/mapper/nvme--vg-swap"; }];
}
