{
  inputs,
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
    config-preservation
    system-identity
    system-lanzaboote
  ]);

  custom.lanzaboote.enable = true;
  custom.systemIdentity = {
    enable = true;
    pcr15 = "83ba5359a075c34462e85021874a6adcd0416a08a31cfbaa0a9faf2e623c64e7";
    luksDevices = [ "cryptroot" ];
  };

  boot = {
    initrd = {
      availableKernelModules = [
        "usbhid"
        "sdhci_pci"
      ];
      kernelModules = [ "dm-snapshot" ];
      supportedFilesystems = {
        btrfs = true;
      };
      systemd = {
        enable = true; # needed to auto-unlock LUKS with TPM
        tpm2.enable = true;
      };
    };
    supportedFilesystems = {
      btrfs = true;
      f2fs = true;
      xfs = true;
      zfs = true; # TODO disable later?
      iso9660 = true;
      udf = true;
    };
  };

  fileSystems."/state".neededForBoot = true;

  custom.preservation = {
    enable = true;
    resetBtrfsRoot.enable = true;
    preserveAtTemplates."/state" = {
      auto.enable = true;
      vm.enable = true;
    };
  };

  hardware = {
    asus.battery.chargeUpto = 80;
    enableRedistributableFirmware = true;
    facter.reportPath = ./facter.json;
  };

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
