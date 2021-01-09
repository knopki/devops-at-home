{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  cfg = config.theme;
  lsColors = builtins.readFile "${nixosConfig.nix.registry.ls-colors.flake.outPath}/LS_COLORS";
in
{
  options.theme.components.dircolors.enable = mkEnableOption "Enable dircolors" // { default = cfg.enable; };

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
