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
  };
}
