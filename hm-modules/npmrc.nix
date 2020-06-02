{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.npmrc.enable = mkEnableOption "npm rc";

  config = mkIf config.knopki.npmrc.enable {
    home.file = {
      ".npmrc".text = ''
        cache="${config.xdg.cacheHome}/npm"
        prefix="${config.xdg.dataHome}/npm"
      '';
    };
  };
}
