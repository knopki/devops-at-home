{ config, username, ... }:
let
  selfHM = config.home-manager.users."${username}";
in {
  dconf = {
    enable = true;
    settings = {
      "system/locale" = {
        region = config.i18n.defaultLocale;
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
}
