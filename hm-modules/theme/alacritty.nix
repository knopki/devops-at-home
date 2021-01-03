{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.theme;
in
{
  options.theme.components.alacritty.enable = mkEnableOption "Apply theme to Alactritty" // { default = cfg.enable; };

  config = mkIf (cfg.enable && cfg.components.alacritty.enable) {
    programs.alacritty.settings = {
      colors = with cfg.base16.colors; {
        primary = {
          background = mkDefault "0x${base00.hex.rgb}";
          foreground = mkDefault "0x${base05.hex.rgb}";
        };

        cursor = {
          text = mkDefault "0x${base00.hex.rgb}";
          cursor = mkDefault "0x${base05.hex.rgb}";
        };

        normal = {
          black = mkDefault "0x${base00.hex.rgb}";
          red = mkDefault "0x${base08.hex.rgb}";
          green = mkDefault "0x${base0B.hex.rgb}";
          yellow = mkDefault "0x${base0A.hex.rgb}";
          blue = mkDefault "0x${base0D.hex.rgb}";
          magenta = mkDefault "0x${base0E.hex.rgb}";
          cyan = mkDefault "0x${base0C.hex.rgb}";
          white = mkDefault "0x${base05.hex.rgb}";
        };

        bright = {
          black = mkDefault "0x${base03.hex.rgb}";
          red = mkDefault "0x${base08.hex.rgb}";
          green = mkDefault "0x${base0B.hex.rgb}";
          yellow = mkDefault "0x${base0A.hex.rgb}";
          blue = mkDefault "0x${base0D.hex.rgb}";
          magenta = mkDefault "0x${base0E.hex.rgb}";
          cyan = mkDefault "0x${base0C.hex.rgb}";
          white = mkDefault "0x${base07.hex.rgb}";
        };

        indexed_colors = [
          { index = 16; color = mkDefault "0x${base03.hex.rgb}"; }
          { index = 17; color = mkDefault "0x${base03.hex.rgb}"; }
          { index = 18; color = mkDefault "0x${base03.hex.rgb}"; }
          { index = 19; color = mkDefault "0x${base03.hex.rgb}"; }
          { index = 20; color = mkDefault "0x${base03.hex.rgb}"; }
          { index = 21; color = mkDefault "0x${base03.hex.rgb}"; }
        ];
      };
    };
  };
}
