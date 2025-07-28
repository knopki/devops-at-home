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
  ++ (with self.modules.nixos; [ mixin-systemd-boot ]);

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

  fileSystems = {
    "/".neededForBoot = true;
    "/nix".neededForBoot = true;
    "/state".neededForBoot = true;
  };

  hardware = {
    asus.battery.chargeUpto = 80;
    enableRedistributableFirmware = true;
    flipperzero.enable = true;
    ledger.enable = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  preservation = {
    enable = true;
    preserveAt."/state" = {
      commonMountOptions = [
        "x-gvfs-hide"
        "x-gdu.hide"
      ];
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/secureboot"
        "/var/lib/bluetooth"
        "/var/lib/fprint"
        "/var/lib/fwupd"
        "/var/lib/libvirt"
        "/var/lib/power-profiles-daemon"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/rfkill"
        "/var/lib/systemd/timers"
        "/var/log"
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
      ];
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
          inInitrd = true;
        }
        "/var/lib/usbguard/rules.conf"

        # creates a symlink on the volatile root
        # creates an empty directory on the persistent volume, i.e. /state/var/lib/systemd
        # does not create an empty file at the symlink's target (would require `createLinkTarget = true`)
        {
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
      ];
    };
  };

  security.tpm2.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [
      "/"
      "/state"
    ];
  };

  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/state/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /state"
    ];
  };
}
