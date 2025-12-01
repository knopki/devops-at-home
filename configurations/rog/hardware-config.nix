{
  inputs,
  pkgs,
  self,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.default
    ./disko-configuration.nix
  ]
  ++ (with inputs.nixos-hardware.nixosModules; [
    asus-zephyrus-ga402x-amdgpu
    asus-battery
    common-pc-laptop
    common-pc-ssd
  ])
  ++ (with self.modules.nixos; [
    profile-systemd-boot
    mixin-preservation-common
  ]);

  profiles.systemd-boot.enable = true;

  boot = {
    bootspec.enable = true;
    initrd = {
      availableKernelModules = [
        "tpm_tis"
        "btrfs"
        "nvme"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
      ];
      kernelModules = [ "dm-snapshot" ];
      supportedFilesystems = {
        btrfs = true;
      };
      systemd = {
        enable = true; # needed to auto-unlock LUKS with TPM
        emergencyAccess = true;
        tpm2.enable = true;
      };
    };
    plymouth.enable = true;
    supportedFilesystems = {
      btrfs = true;
      f2fs = true;
      xfs = true;
      zfs = true; # TODO disable later?
      iso9660 = true;
      udf = true;
    };
  };

  hardware = {
    asus.battery.chargeUpto = 80;
    enableAllFirmware = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  preservation.enable = true;

  security.tpm2.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [
      "/"
      "/state"
      "/state/sensitive"
    ];
  };
}
