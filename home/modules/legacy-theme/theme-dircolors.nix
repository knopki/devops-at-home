{
  config,
  lib,
  pkgs,
  packages,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkDefault mkBefore concatStringsSep;
  cfg = config.theme;
  lsColors = builtins.readFile "${packages.ls-colors}/LS_COLORS";
in {
  options.theme.components.dircolors.enable = mkEnableOption "Enable dircolors" // {default = cfg.enable;};

  config = mkIf (cfg.enable && cfg.components.dircolors.enable) {
    programs.dircolors = {
      enable = mkDefault true;
      extraConfig = mkBefore (concatStringsSep "\n" [
        lsColors
        "TERM alacritty"
      ]);
    };
  };
}
