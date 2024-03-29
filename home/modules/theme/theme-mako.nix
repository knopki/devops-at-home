{ config, options, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkDefault mkIf mkAfter;
  cfg = config.theme;
in
{
  options.theme.components.mako.enable = mkEnableOption "Apply theme to Mako" // {
    default = options ? programs.mako && config.programs.mako.enable;
  };

  config = mkIf (cfg.enable && cfg.components.mako.enable && options ? programs.mako) (with cfg.base16.colors; {
    programs.mako = {
      backgroundColor = mkDefault "#${base00.hex.rgb}";
      textColor = mkDefault "#${base05.hex.rgb}";
      borderColor = mkDefault "#${base0D.hex.rgb}";
      font = "pango:${cfg.fonts.regular.family} ${toString cfg.fonts.regular.size}";
    };

    xdg.configFile."mako/config".text = mkAfter ''
      [urgency=low]
      background-color=#${base00.hex.rgb}
      text-color=#${base04.hex.rgb}
      border-color=#${base0D.hex.rgb}

      [urgency=high]
      background-color=#${base01.hex.rgb}
      text-color=#${base06.hex.rgb}
      border-color=#${base08.hex.rgb}
    '';
  });
}
