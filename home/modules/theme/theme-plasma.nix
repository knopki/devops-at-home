{ config, lib, pkgs, ... }:
let
  inherit (lib)
    hm mkIf mkMerge mkDefault mkEnableOption;
  cfg = config.theme;
  isDarkTheme = cfg.base16.kind == "dark";
  iconTheme = {
    name = if isDarkTheme then "Papirus-Dark" else "Papirus";
    package = pkgs.papirus-icon-theme;
  };
  gtkTheme = {
    name = if isDarkTheme then "Arc-Dark" else "Arc";
    package = pkgs.arc-theme;
  };
  kdeThemePkg = pkgs.arc-kde-theme;
  kvColorScheme = if isDarkTheme then "KvArcDark" else "KvArc";
  kdeThemeId = if isDarkTheme then "com.github.varlesh.arc-dark" else "com.github.varlesh.arc";

  gtkSettingsRc = {
    Settings = {
      gtk-font-name = config.gtk.font.name;
      gtk-application-prefer-dark-theme = config.gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme;
      gtk-icon-theme-name = config.gtk.iconTheme.name;
      gtk-theme-name = config.gtk.theme.name;
    };
  };

  mkKDEFontList = name: size: [ name size "-1" 5 50 0 0 0 0 0 ];
in
{
  options.theme.components.plasma = {
    enable = mkEnableOption "Apply theme to KDE Plasma";
  };

  config = mkIf (cfg.enable && cfg.components.plasma.enable) {
    assertions = [
      {
        assertion = !config.gtk.enable;
        message = "theme.componenets.plasma: conflict with gtk.enable - gtk configuration managed by KDE";
      }
      {
        assertion = !cfg.components.gtk.enable;
        message = "theme.componenets.plasma: conflict with theme.components.gtk.enable - gtk configuration managed by KDE";
      }
    ];

    home.packages = with pkgs; [
      libsForQt5.qtstyleplugin-kvantum
      kdeThemePkg
      iconTheme.package
      gtkTheme.package
    ];

    gtk = {
      inherit iconTheme;
      theme = gtkTheme;
      font = {
        name = "${cfg.fonts.regular.family}, ${toString cfg.fonts.regular.size}";
        package = cfg.fonts.regular.package;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = isDarkTheme;
      };
    };

    dconf.settings = {
      "org/gnome/desktop/wm/preferences".theme = config.gtk.theme.name;
      "org/gnome/desktop/interface" = {
        document-font-name = mkDefault "${cfg.fonts.document.family} ${toString cfg.fonts.document.size}";
        monospace-font-name = mkDefault "${cfg.fonts.monospace.family} ${toString cfg.fonts.monospace.size}";
      };
    };

    programs.kde.settings = {
      "gtk-3.0/settings.ini" = gtkSettingsRc;
      "gtk-4.0/settings.ini" = gtkSettingsRc;

      kdeglobals = {
        General = {
          Name = if isDarkTheme then "Arc Dark" else "Arc Color";
          ColorScheme = kvColorScheme;
          fixed = mkKDEFontList cfg.fonts.monospace.family cfg.fonts.monospace.size;
          font = mkKDEFontList cfg.fonts.regular.family cfg.fonts.regular.size;
          menuFont = mkKDEFontList cfg.fonts.regular.family cfg.fonts.regular.size;
          toolBarFont = mkKDEFontList cfg.fonts.regular.family cfg.fonts.regular.size;
          smallestReadableFont = mkKDEFontList cfg.fonts.regular.family (cfg.fonts.regular.size - 2);
        };
        WM = {
          frame = [ 61 174 233 ];
          inactiveFrame = [ 239 240 241 ];
        };
        Icons.Theme = iconTheme.name;
        KDE = {
          LookAndFeelPackage = kdeThemeId;
          widgetStyle = if isDarkTheme then "kvantum-dark" else "kvantum";
        };
      };

      "Kvantum/kvantum.kvconfig".General.theme = kvColorScheme;

      kwinrc = {
        Effect-Slide.Duration = mkDefault 100;
        Effect-kwin4_effect_translucency.Inactive = mkDefault 80;
        "org.kde.kdecoration2" = {
          library = "org.kde.kwin.aurorae";
          theme = if isDarkTheme then "__aurorae__svg__Arc-Dark" else "__aurorae__svg__Arc";
          BorderSizeAuto = mkDefault false;
        };
      };

      kscreenlockerrc = {
        Greeter.Theme = kdeThemeId;
        Daemon.Timeout = 15;
      };

      ksplashrc = {
        Engine = "KSplashQML";
        KSplash.Theme = kdeThemeId;
      };

      kxkbrc.Layout = {
        ShowFlag = mkDefault false;
        ShowLabel = mkDefault true;
        ShowLayoutIndicator = mkDefault true;
      };

      plasmarc = {
        Theme.name = if isDarkTheme then "Arc-Dark" else "Arc-Color";
      };
    };
  };
}
