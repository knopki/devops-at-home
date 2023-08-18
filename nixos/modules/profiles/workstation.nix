{
  lib,
  pkgs,
  self,
  ...
}: {
  imports = with self.nixosModules; [
    home-manager
  ];
  config = {
    system.stateVersion = "23.06";
    fileSystems."/" = {
      device = "/dev/sda";
      fsType = "auto";
    };
    boot.loader.grub.devices = ["/dev/sda"];
  };
}
