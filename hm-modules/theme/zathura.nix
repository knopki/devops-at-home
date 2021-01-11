{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  cfg = config.theme;
in
{
  options.theme.components.zathura.enable = mkEnableOption "Apply theme to Zathura" // { default = cfg.enable; };

  config = mkIf (cfg.enable && cfg.components.zathura.enable) (mkMerge [
    {
      programs.zathura.options.font = "${cfg.fonts.regular.family} ${toString cfg.fonts.regular.size}";
    }

    (mkIf (!elem cfg.preset [ "dracula" ]) {
      programs.zathura = {
        options = with cfg.base16.colors; {
          default-bg = mkDefault "#${base00.hex.rgb}";
          default-fg = mkDefault "#${base01.hex.rgb}";
          statusbar-fg = mkDefault "#${base04.hex.rgb}";
          statusbar-bg = mkDefault "#${base02.hex.rgb}";
          inputbar-bg = mkDefault "#${base00.hex.rgb}";
          inputbar-fg = mkDefault "#${base07.hex.rgb}";
          notification-bg = mkDefault "#${base00.hex.rgb}";
          notification-fg = mkDefault "#${base07.hex.rgb}";
          notification-error-bg = mkDefault "#${base00.hex.rgb}";
          notification-error-fg = mkDefault "#${base08.hex.rgb}";
          notification-warning-bg = mkDefault "#${base00.hex.rgb}";
          notification-warning-fg = mkDefault "#${base08.hex.rgb}";
          highlight-color = mkDefault "#${base0A.hex.rgb}";
          highlight-active-color = mkDefault "#${base0D.hex.rgb}";
          completion-bg = mkDefault "#${base01.hex.rgb}";
          completion-fg = mkDefault "#${base0D.hex.rgb}";
          completion-highlight-fg = mkDefault "#${base07.hex.rgb}";
          completion-highlight-bg = mkDefault "#${base0D.hex.rgb}";
          recolor-lightcolor = mkDefault "#${base00.hex.rgb}";
          recolor-darkcolor = mkDefault "#${base06.hex.rgb}";
          recolor = mkDefault true;
          adjust-open = mkDefault "width";
        };
      };
    })


    (mkIf (cfg.preset == "dracula") {
      programs.zathura.extraConfig = mkBefore (builtins.readFile
        "${nixosConfig.nix.registry.dracula-zathura.flake.outPath}/zathurarc");
    })
  ]);
}
