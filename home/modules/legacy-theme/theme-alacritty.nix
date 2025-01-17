{
  config,
  lib,
  pkgs,
  packages,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    elem
    ;
  cfg = config.theme;
in
{
  options.theme.components.alacritty.enable = mkEnableOption "Apply theme to Alactritty" // {
    default = config.programs.alacritty.enable;
  };

  config = mkIf (cfg.enable && cfg.components.alacritty.enable) (mkMerge [
    {
      programs.alacritty.settings = {
        font = {
          normal = {
            family = cfg.fonts.monospace.family;
          };
          size = cfg.fonts.monospace.size;
        };
      };
    }

    (mkIf (!elem cfg.preset [ "dracula" ]) {
      programs.alacritty.settings = {
        colors = with cfg.base16.colors; {
          primary = {
            background = "0x${base00.hex.rgb}";
            foreground = "0x${base05.hex.rgb}";
          };

          cursor = {
            text = "0x${base00.hex.rgb}";
            cursor = "0x${base05.hex.rgb}";
          };

          normal = {
            black = "0x${base00.hex.rgb}";
            red = "0x${base08.hex.rgb}";
            green = "0x${base0B.hex.rgb}";
            yellow = "0x${base0A.hex.rgb}";
            blue = "0x${base0D.hex.rgb}";
            magenta = "0x${base0E.hex.rgb}";
            cyan = "0x${base0C.hex.rgb}";
            white = "0x${base05.hex.rgb}";
          };

          bright = {
            black = "0x${base03.hex.rgb}";
            red = "0x${base08.hex.rgb}";
            green = "0x${base0B.hex.rgb}";
            yellow = "0x${base0A.hex.rgb}";
            blue = "0x${base0D.hex.rgb}";
            magenta = "0x${base0E.hex.rgb}";
            cyan = "0x${base0C.hex.rgb}";
            white = "0x${base07.hex.rgb}";
          };

          indexed_colors = [
            {
              index = 16;
              color = "0x${base03.hex.rgb}";
            }
            {
              index = 17;
              color = "0x${base03.hex.rgb}";
            }
            {
              index = 18;
              color = "0x${base03.hex.rgb}";
            }
            {
              index = 19;
              color = "0x${base03.hex.rgb}";
            }
            {
              index = 20;
              color = "0x${base03.hex.rgb}";
            }
            {
              index = 21;
              color = "0x${base03.hex.rgb}";
            }
          ];
        };
      };
    })

    (mkIf (cfg.preset == "dracula") {
      xdg.configFile."alacritty/dracula.toml".source = "${packages.dracula-alacritty}/dracula.toml";
      programs.alacritty.settings.general.import = [ "dracula.toml" ];
    })
  ]);
}
