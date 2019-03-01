{ config, lib, pkgs, ... }:
with builtins;
let
  username = "sk";
  userSk = (import ./lib/users/sk) {
    inherit config lib pkgs username;
  };
in {
  imports = [
    ./modules
    ./modules/workstation.nix
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  boot = {
    extraModprobeConfig = ''
      blacklist snd-intel8x0m
      options snd_hda_intel position_fix=1
      options i8k force=1
    '';
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "ehci_pci"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
        "dm_persistent_data"
        "dm_multipath"
      ];

      extraUtilsCommands = ''
        copy_bin_and_libs ${pkgs.thin-provisioning-tools}/bin/pdata_tools
        copy_bin_and_libs ${pkgs.thin-provisioning-tools}/bin/thin_check
      ''; # hack to boot on thin pool

      kernelModules = [ "dm_thin_pool" ]; # hack to boot on thin pool

      luks.devices = [
        {
          name = "luks-nvme";
          device = "/dev/vda3";
          preLVM = true;
          allowDiscards = true;
        }
        {
          name = "luks-sata";
          device = "/dev/vdb1";
          preLVM = true;
          allowDiscards = true;
        }
      ];

      preLVMCommands = ''
        mkdir -p /etc/lvm
        echo "global/thin_check_executable = \"$(which thin_check)\"" >> /etc/lvm/lvm.conf
      ''; # hack to boot on thin pool
    };

    kernelModules = [ "dm_thin_pool" ]; # hack to boot on thin pool

    kernelParams = [
      "quiet"
      "splash"
      "resume=/dev/mapper/alien--vg-swap"
      "acpiphp.disable=1"
      "nohz_full=1-7"
      "drm.rnodes=1"
    ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  environment.etc = {
    "lvm/lvm.conf" = {
      text = ''
        activation {
          activation_mode = "partial"
        }
        devices {
          issue_discards = 1
        }
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    thin-provisioning-tools # required to boot on the encrypted lvm thin pool
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/80a2378d-62a9-4115-b8c0-6660e7800944";
      fsType = "ext4";
      options = ["relatime" "discard"];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/f95ecea9-05b3-4332-9431-1b96f53189c9";
      fsType = "ext4";
      options = ["relatime" "discard"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/821A-938A";
      fsType = "vfat";
    };
  };

  hardware = {
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;
    opengl.driSupport32Bit = true;
    pulseaudio = {
      extraConfig = ''
        load-module module-alsa-sink device=hw:0,0 sink_properties=device.description="Analog-Output" control=PCM
        load-module module-alsa-sink device=hw:0,1 sink_properties=device.description="HDMI-Output" control=PCM
      '';
      support32Bit = true;
    };
  };

  home-manager.users."${username}" = userSk.hm;
  home-manager.useUserPackages = true;

  networking = {
    hostId = "ff0b9d65";
    hostName = "alien-test";
    search = [ "1984.run" ];
  };

  nix.maxJobs = lib.mkDefault 4;

  services = {
    fstrim.enable = true;
    spice-vdagentd.enable = true;
    qemuGuest.enable = true;
  };

  swapDevices = [
    {
      device = "/dev/mapper/alien--vg-swap";
    }
  ];

  users.groups = userSk.groups;
  users.users."${username}" = userSk.systemUser;
}
