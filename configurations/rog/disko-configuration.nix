# apply with:
#  sudo nix --experimental-features "nix-command flakes" run nixpkgs#disko -- \
#   -m format,mount -f .#rog --root-mountpoint=/mnt
let
  btrfsDefaults = {
    extraArgs = [
      "--csum xxhash64"
      "--features"
      "block-group-tree"
    ];
    mountOptions = [
      "compress=zstd"
      "relatime"
      "ssd"
      "space_cache=v2"
      "discard=async"
    ];
  };
in
{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        name = "nvme0n1";
        device = "/dev/disk/by-id/nvme-Micron_2450_MTFDKBA1T0TFK_2147334415A8_1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1024M";
              type = "EF00";
              label = "esp";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              label = "cryptroot";
              content = {
                type = "luks";
                name = "cryptroot";
                askPassword = true; # ask initial password
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [
                    "tmp2-device=auto"
                    "tpm2-measure-pcr=yes"
                  ];
                };
                content = {
                  type = "lvm_pv";
                  vg = "root_vg";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      root_vg = {
        type = "lvm_vg";
        lvs = {
          swap = {
            size = "40G";
            content = {
              type = "swap";
              priority = 100;
              resumeDevice = true;
            };
          };
          sys = {
            size = "100G";
            content = {
              inherit (btrfsDefaults) extraArgs;
              type = "btrfs";
              # Subvolumes must set a mountpoint in order to be mounted,
              # unless their parent is mounted
              subvolumes = {
                "@" = {
                  inherit (btrfsDefaults) mountOptions;
                  mountpoint = "/";
                };
                "@root-blank" = {
                  inherit (btrfsDefaults) mountOptions;
                };
                "@nix" = {
                  inherit (btrfsDefaults) mountOptions;
                  mountpoint = "/nix";
                };
              };
            };
          };
          state = {
            size = "100%";
            content = {
              inherit (btrfsDefaults) extraArgs;
              type = "btrfs";
              subvolumes = {
                "@state" = {
                  inherit (btrfsDefaults) mountOptions;
                  mountpoint = "/state";
                };
                "@state/var" = { };
                "@state/srv" = { };
                "@state/root" = { };
                "@state/home" = { };
                "@state/home/knopki" = { };
              };
            };
          };
          sensitive = {
            size = "1G";
            content = {
              inherit (btrfsDefaults) extraArgs;
              type = "btrfs";
              subvolumes = {
                "@sensitive" = {
                  mountpoint = "/state/sensitive";
                  mountOptions = btrfsDefaults.mountOptions ++ [
                    # "noauto"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
