{ config, lib, pkgs, ... }:
with builtins;
let
  luksCommon = {
    preLVM = true;
    allowDiscards = true;
    keyFile = "/dev/disk/by-id/usb-USB_Flash_Disk_CCYYMMDDHHmmSS71FZGI-0:0";
    keyFileOffset = 512 * 8;
    keyFileSize = 512 * 8;
    fallbackToPassword = true;
  };
  swapDevice = "/dev/disk/by-uuid/4e383ae0-75f6-406a-a83d-1d9b07eff4cc";
in
{
  imports =
    [ ../modules <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot = {
    extraModprobeConfig = ''
      options snd_hda_intel index=0 model=alienware enable_msi=1 position_fix=0
      options i8k force=1
      options i915 enable_fbc=1 enable_guc=3 enable_psr=1
    '';
    extraModulePackages = [];
    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "usb_storage"
        "xhci_pci"
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
    bluetooth.enable = true;
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
        WOL_DISABLE=Y
      '';
    };
    zerotierone = {
      enable = true;
      joinNetworks = [ "1c33c1ced08df9ac" "0cccb752f7043dce" ];
    };
  };

  swapDevices = [ { device = swapDevice; } ];
}
