{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  cfg = config.theme;
  template = "${nixosConfig.nix.registry.base16-textmate.flake.outPath}/templates/default.mustache";
  themeFile = pkgs.runCommandLocal "hm-bat-theme" { } ''
    sed '${
      concatStrings
      (mapAttrsToList (n: v: "s/#{{${n}-hex}}/#${v.hex.rgb}/;") cfg.base16.colors)
    }' ${template} > $out
  '';
in
{
  options.theme.components.bat.enable = mkEnableOption "Apply theme to Bat" // { default = cfg.enable; };

  config = mkIf (cfg.enable && cfg.components.bat.enable) (mkMerge [
    (mkIf (!elem cfg.preset [ "dracula" ]) {
      programs.bat =
        let
          themeName = "Base16 ${cfg.base16.name}";
        in
        {
          config.theme = mkDefault themeName;
          themes."${themeName}" = builtins.readFile themeFile;
        };
      xdg.configFile."bat/themes/HmBase16.tmTheme".onChange =
        "${pkgs.bat}/bin/bat cache --build";
    })

    (mkIf (cfg.preset == "dracula") {
      programs.bat.config.theme = mkDefault "Dracula";
    })
  ]);
}
