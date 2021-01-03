{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  cfg = config.theme;
in
{
  options.theme.components.gnome-terminal.enable = mkEnableOption "Apply theme to Gnome Terminal" // { default = cfg.enable; };

  config = mkIf (cfg.enable && cfg.components.gnome-terminal.enable) {
    # @author Robert Helgesson
    programs.gnome-terminal = {
      themeVariant = cfg.base16.kind;
      profile."b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
        visibleName = mkDefault "Home Manager - Base16";
        colors = {
          backgroundColor = mkDefault "#${colors.base00.hex.rgb}";
          foregroundColor = mkDefault "#${colors.base05.hex.rgb}";
          cursor = {
            background = mkDefault "#${colors.base05.hex.rgb}";
            foreground = mkDefault "#${colors.base00.hex.rgb}";
          };
          palette = mkDefault [
            "#${colors.base00.hex.rgb}"
            "#${colors.base08.hex.rgb}"
            "#${colors.base0B.hex.rgb}"
            "#${colors.base0A.hex.rgb}"
            "#${colors.base0D.hex.rgb}"
            "#${colors.base0E.hex.rgb}"
            "#${colors.base0C.hex.rgb}"
            "#${colors.base05.hex.rgb}"
            "#${colors.base03.hex.rgb}"
            "#${colors.base09.hex.rgb}"
            "#${colors.base01.hex.rgb}"
            "#${colors.base02.hex.rgb}"
            "#${colors.base04.hex.rgb}"
            "#${colors.base06.hex.rgb}"
            "#${colors.base0F.hex.rgb}"
            "#${colors.base07.hex.rgb}"
          ];
        };
      };
    };
  };
}
