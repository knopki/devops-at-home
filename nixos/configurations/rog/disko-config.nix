# apply with:
#  sudo nix --experimental-features "nix-command flakes" run nixpkgs#disko -- \
#   -m format,mount -f .#rog --root-mountpoint=/mnt
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
            # Provisioned with:
            #  1. systemd-cryptenroll /dev/nvme0n1p2 --password
            #  2. systemd-cryptenroll /dev/nvme0n1p2 --recovery
            #  3. systemd-cryptenroll /dev/nvme0n1p2 --tpm2-device=auto \
            #       --tpm2-pcrs=0+2+7+12 --tpm2-with-pin=true
            #  4. TODO: FIDO2
            luks = {
              size = "100%";
              label = "cryptroot";
              content = {
                type = "luks";
                name = "cryptroot";
                passwordFile = "/tmp/disk.key"; # initial password
                settings = {
                  allowDiscards = true;
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
            size = "16G";
            content = {
              type = "swap";
              priority = 100;
              resumeDevice = true;
            };
          };
          sys = {
            size = "200G";
            content = {
              type = "btrfs";
              # Subvolumes must set a mountpoint in order to be mounted,
              # unless their parent is mounted
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "relatime"
                  ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
          state = {
            size = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                "@state" = {
                  mountpoint = "/state";
                  mountOptions = [
                    "compress=zstd"
                    "relatime"
                  ];
                };
                "@state/srv" = { };
                "@state/home" = { };
                "@state/home/knopki" = { };
              };
            };
          };
        };
      };
    };
  };
}
