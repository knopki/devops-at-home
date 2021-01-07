{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  cfg = config.theme;
  template = "${nixosConfig.nix.registry.base16-tmux.flake.outPath}/templates/default.mustache";
  themeFile = pkgs.runCommandLocal "hm-tmux-theme" { } ''
    sed '${
      concatStrings
      (mapAttrsToList (n: v: "s/#{{${n}-hex}}/#${v.hex.rgb}/;") cfg.base16.colors)
    }' ${template} > $out
  '';
in
{
  options.theme.components.tmux.enable = mkEnableOption "Apply theme to tmux" // { default = cfg.enable; };

  config = mkIf (cfg.enable && cfg.components.tmux.enable) {
    programs.tmux.extraConfig = mkBefore ''
      source-file ${themeFile}
    '';
  };
}
