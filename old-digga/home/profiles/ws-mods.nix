{
  lib,
  nixosConfig,
  ...
}: let
  inherit (lib) mkDefault;
in {
  programs = {
    git.delta.enable = mkDefault true;
    man.generateCaches = mkDefault true;
  };
}
