{ config, lib, pkgs, user, nixosConfig, ... }:
with lib;
{
  options.local.gnome.enable = mkEnableOption "setup gnome";

  config = mkIf config.local.gnome.enable {
    home.packages = with pkgs; [
      gnome3.rhythmbox
    ];

    dconf = {
      enable = true;
      settings = {
        "system/locale" = {
          region = nixosConfig.i18n.defaultLocale;
        };

        "org/gnome/nautilus/preferences" = {
          search-view = "list-view";
          default-folder-viewer = "icon-view";
          search-filter-time-type = "last_modified";
          show-move-to-trash-shortcut-changed-dialog = false;
        };

        "org/gnome/desktop/interface" = {
          clock-show-date = true;
          show-battery-percentage = true;
          cursor-theme = "Adwaita";
          gtk-theme = "Adwaita-dark";
          icon-theme = "Adwaita";
        };

        "org/gnome/desktop/peripherals/touchpad" = {
          natural-scroll = false;
        };

        "org/gtk/settings/file-chooser" = {
          sort-column = "name";
          show-size-column = true;
          show-hidden = false;
          sort-directories-first = true;
          sort-order = "ascending";
        };
      };
    };

    gtk = {
      enable = true;
      font.name = "Sans Serif 10";
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 0;
        gtk-button-images = 1;
        gtk-enable-primary-paste = 1;
        gtk-fallback-icon-theme = "hicolor";
        gtk-menu-images = 1;
        gtk-primary-button-warps-slider = 0;
      };
    };

    local.envd = {
      "50-gnome" = {
        # CLUTTER_BACKEND = "wayland";
        # GDK_BACKEND = "wayland";
        GTK_RC_FILES = "${config.xdg.configHome}/gtk-1.0/gtkrc";
        GTK2_RC_FILES = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        XDG_CURRENT_DESKTOP = "GNOME";
      };
    };
  };
}