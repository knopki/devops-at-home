{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  cfg = config.theme;
  materiaTheme = rec {
    name = "Materia-Base16-${cfg.base16.name}";
    package = pkgs.materia-theme.overrideAttrs (o: {
      nativeBuildInputs = o.nativeBuildInputs ++ (with pkgs; [ inkscape optipng ]);

      theme = with cfg.base16.colors; (lib.generators.toKeyValue { } {
        # Color selection copied from
        # https://github.com/pinpox/nixos-home/blob/1cefe28c72930a0aed41c20d254ad4d193a3fa37/gtk.nix#L11
        ACCENT_BG = base0B.hex.rgb;
        ACCENT_FG = base00.hex.rgb;
        BG = base00.hex.rgb;
        BTN_BG = base02.hex.rgb;
        BTN_FG = base06.hex.rgb;
        FG = base05.hex.rgb;
        HDR_BG = base02.hex.rgb;
        HDR_BTN_BG = base01.hex.rgb;
        HDR_BTN_FG = base05.hex.rgb;
        HDR_FG = base05.hex.rgb;
        MATERIA_SURFACE = base02.hex.rgb;
        MATERIA_VIEW = base01.hex.rgb;
        MENU_BG = base02.hex.rgb;
        MENU_FG = base06.hex.rgb;
        SEL_BG = base0D.hex.rgb;
        SEL_FG = base0E.hex.rgb;
        TXT_BG = base02.hex.rgb;
        TXT_FG = base06.hex.rgb;
        WM_BORDER_FOCUS = base05.hex.rgb;
        WM_BORDER_UNFOCUS = base03.hex.rgb;

        MATERIA_COLOR_VARIANT = cfg.base16.kind;
        MATERIA_STYLE_COMPACT = "True";
        UNITY_DEFAULT_LAUNCHER_STYLE = "False";
        NAME = name;
      });
      passAsFile = [ "theme" ];

      postPatch = ''
        patchShebangs .
        export HOME="$NIX_BUILD_ROOT"
        ./change_color.sh -t $out/share/themes -o "${name}" "$themePath"
      '';
    });
  };
  papirusIcons = { name = "Papirus"; package = pkgs.papirus-icon-theme; };
  draculaTheme = { name = "Dracula"; package = pkgs.dracula-theme; };
  draculaIcons = { name = "Dracula"; package = pkgs.dracula-theme-icons; };
in
{
  options.theme.components.gtk.enable = mkEnableOption "Apply theme to Gtk" // { default = cfg.enable; };

  config = mkIf (cfg.enable && cfg.components.gtk.enable) (mkMerge [
    {
      dconf.settings."org/gnome/desktop/interface" = {
        document-font-name = mkDefault "${cfg.fonts.document.family} ${toString cfg.fonts.document.size}";
        monospace-font-name = mkDefault "${cfg.fonts.monospace.family} ${toString cfg.fonts.monospace.size}";
      };
      gtk = {
        font = {
          name = "${cfg.fonts.regular.family} ${toString cfg.fonts.regular.size}";
          package = null;
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = mkDefault (
            if (cfg.base16.kind == "dark") then 1 else 0
          );
          gtk-fallback-icon-theme = mkDefault "hicolor";
        };
      };
    }

    (mkIf (!elem cfg.preset [ "dracula" ]) {
      dconf.settings = {
        "org/gnome/desktop/wm/preferences".theme = materiaTheme.name;
      };
      gtk.theme = materiaTheme;
      gtk.iconTheme = papirusIcons;
    })

    (mkIf (cfg.preset == "dracula") {
      dconf.settings = {
        "org/gnome/desktop/wm/preferences".theme = draculaTheme.name;
      };
      gtk.theme = draculaTheme;
      gtk.iconTheme = draculaIcons;
    })
  ]);
}
