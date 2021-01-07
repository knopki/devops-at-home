{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  cfg = config.theme;
  template = "${nixosConfig.nix.registry.base16-waybar.flake.outPath}/templates/default.mustache";
  themeFile = pkgs.runCommandLocal "hm-waybar-theme" { } ''
    sed '${
      concatStrings
      (mapAttrsToList (n: v: "s/#{{${n}-hex}}/#${v.hex.rgb}/;") cfg.base16.colors)
    }' ${template} > $out
  '';
in
{
  options.theme.components.waybar.enable = mkEnableOption "Apply theme to Waybar" // { default = cfg.enable; };

  config = mkIf (cfg.enable && cfg.components.waybar.enable) {
    xdg.configFile."waybar/style.css".text = mkBefore (builtins.readFile themeFile);
  };
}
