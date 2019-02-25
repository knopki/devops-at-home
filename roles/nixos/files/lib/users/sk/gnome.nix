{ config, ... }:
{
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
}
