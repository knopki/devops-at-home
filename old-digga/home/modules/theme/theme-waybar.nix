{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkBefore
    concatStrings
    concatStringsSep
    mapAttrsToList
    ;
  cfg = config.theme;
  template = "${pkgs.base16-waybar}/templates/default.mustache";
  themeFile = pkgs.runCommandLocal "hm-waybar-theme" {} ''
    sed '${
      concatStrings
      (mapAttrsToList (n: v: "s/#{{${n}-hex}}/#${v.hex.rgb}/;") cfg.base16.colors)
    }' ${template} > $out
  '';
  fontsSetup = ''
    * {
      font-family: ${cfg.fonts.regular.family}, Helvetica, Arial, sans-serif;
      font-size: ${toString (cfg.fonts.regular.size + 2)}px;
    }
  '';
in {
  options.theme.components.waybar.enable =
    mkEnableOption "Apply theme to Waybar"
    // {
      default = options ? programs.waybar && config.programs.waybar.enable;
    };

  config = mkIf (cfg.enable && cfg.components.waybar.enable && options ? programs.waybar) {
    xdg.configFile."waybar/style.css".text = mkBefore (concatStringsSep "\n" [
      (builtins.readFile themeFile)
      fontsSetup
    ]);
  };
}
