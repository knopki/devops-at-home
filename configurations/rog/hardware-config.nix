{
  inputs,
  pkgs,
  self,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402x-amdgpu
    inputs.nixos-hardware.nixosModules.asus-battery
    inputs.disko.nixosModules.default
    ./disko-configuration.nix
  ]
  ++ (with self.modules.nixos; [
    mixin-systemd-boot
    mixin-preservation-common
  ]);

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

  environment.systemPackages = with pkgs; [
    nvme-cli
    pciutils
    sbctl # secure boot key manager
    smartmontools # for diagnosing hard disks
    usbutils
  ];

  hardware = {
    asus.battery.chargeUpto = 80;
    enableRedistributableFirmware = true;
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
