{ config, lib, pkgs, ... }:
with builtins;
let
  luksCommon = {
    preLVM = true;
    allowDiscards = true;
    keyFile = "/dev/disk/by-id/usb-USB_Flash_Disk_CCYYMMDDHHmmSSU1QI0L-0:0";
    keyFileOffset = 16;
    keyFileSize = 4096;
    fallbackToPassword = true;
  };
in
{
  imports =
    [ ../modules <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot = {
    extraModulePackages = [];
    initrd = {
      availableKernelModules = [
        "ahci"
        "ehci_pci"
        "sd_mod"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [ "dm-snapshot" ];

      luks.devices = {
        "luks-ssd" = (
          luksCommon // {
            device = "/dev/disk/by-uuid/5c68ca95-33d9-476e-8864-15d163f39de3";
          }
        );
      };
    };

    kernelParams = [];

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
      device = "/dev/disk/by-uuid/fe6d8424-96e3-44a4-b939-37d89bfa401d";
      fsType = "ext4";
      options = [ "relatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/C6B9-4E1F";
      fsType = "vfat";
    };
    "/boot.bak" = {
      device = "/dev/disk/by-uuid/C69C-9B91";
      fsType = "vfat";
    };
  };

  local = {
    hardware.intel = true;
    roles.essential.enable = true;
    users.setupUsers = [ "sk" ];
  };

  networking = {
    hostId = "f2c8a36b";
    hostName = "jupiter";
    search = [ "1984.run" ];

    interfaces.enp3s0 = { useDHCP = true; };
    interfaces.enp4s0 = { useDHCP = false; };
  };

  nix.maxJobs = lib.mkDefault 4;

  services = {
    fstrim.enable = true;
    zerotierone = {
      enable = true;
      joinNetworks = [ "1c33c1ced08df9ac" ];
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/dc4b1587-1124-46bd-91c8-fdde50f8b610"; } ];

  system.activationScripts.backupEFI = {
    text = "${pkgs.rsync}/bin/rsync -azu --delete -h /boot/ /boot.bak";
    deps = [];
  };
}
