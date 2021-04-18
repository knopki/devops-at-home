{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  dconf = {
    enable = true;
    settings = {
      "org/gnome/nautilus/preferences" = {
        search-view = "list-view";
        default-folder-viewer = "icon-view";
        search-filter-time-type = "last_modified";
        show-move-to-trash-shortcut-changed-dialog = false;
      };

      "org/gnome/desktop/interface" = {
        clock-show-date = true;
        show-battery-percentage = true;
      };

      "org/gnome/desktop/peripherals/touchpad".natural-scroll = mkDefault false;

      "org/gtk/settings/file-chooser" = {
        sort-column = "name";
        show-size-column = true;
        show-hidden = false;
        sort-directories-first = true;
        sort-order = "ascending";
      };

      "org/pantheon/desktop/gala/appearance" = {
        button-layout = ":minimize,maximize,close";
      };
    };
  };
}
