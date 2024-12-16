{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.theme;
in {
  options.theme.components.gnome-terminal.enable =
    mkEnableOption "Apply theme to Gnome Terminal"
    // {
      default = config.programs.gnome-terminal.enable;
    };

  config = mkIf (cfg.enable && cfg.components.gnome-terminal.enable) {
    programs.gnome-terminal = {
      themeVariant = cfg.base16.kind;
      profile."ea538469-ab30-4a5c-8874-5eca6ab1f081" = with cfg.base16.colors; {
        visibleName = mkDefault "Home Manager - Base16 ${cfg.base16.name}";
        colors = {
          backgroundColor = mkDefault "#${base00.hex.rgb}";
          foregroundColor = mkDefault "#${base05.hex.rgb}";
          cursor = {
            background = mkDefault "#${base05.hex.rgb}";
            foreground = mkDefault "#${base00.hex.rgb}";
          };
          palette = mkDefault [
            "#${base00.hex.rgb}"
            "#${base08.hex.rgb}"
            "#${base0B.hex.rgb}"
            "#${base0A.hex.rgb}"
            "#${base0D.hex.rgb}"
            "#${base0E.hex.rgb}"
            "#${base0C.hex.rgb}"
            "#${base05.hex.rgb}"
            "#${base03.hex.rgb}"
            "#${base09.hex.rgb}"
            "#${base01.hex.rgb}"
            "#${base02.hex.rgb}"
            "#${base04.hex.rgb}"
            "#${base06.hex.rgb}"
            "#${base0F.hex.rgb}"
            "#${base07.hex.rgb}"
          ];
        };
      };
    };
  };
}
