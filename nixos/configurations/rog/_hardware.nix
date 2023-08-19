{
  config,
  lib,
  pkgs,
  ...
}: {
  fileSystems."/" = {
    device = "/dev/sda";
    fsType = "auto";
  };
  boot.loader.grub.devices = ["/dev/sda"];
}
