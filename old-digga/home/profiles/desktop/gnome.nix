{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
in {
  home.packages = [pkgs.dconf];
  dconf = {
    enable = mkDefault true;
    settings = {
      "org/gnome/nautilus/preferences" = {
        search-view = mkDefault "list-view";
        default-folder-viewer = mkDefault "icon-view";
        search-filter-time-type = mkDefault "last_modified";
        show-move-to-trash-shortcut-changed-dialog = mkDefault false;
      };

      "org/gnome/desktop/interface" = {
        clock-show-date = mkDefault true;
        show-battery-percentage = mkDefault true;
      };

      "org/gnome/desktop/peripherals/touchpad".natural-scroll = mkDefault false;

      "org/gtk/settings/file-chooser" = {
        sort-column = mkDefault "name";
        show-size-column = mkDefault true;
        show-hidden = mkDefault false;
        sort-directories-first = mkDefault true;
        sort-order = mkDefault "ascending";
      };

      "org/pantheon/desktop/gala/appearance" = {
        button-layout = mkDefault ":minimize,maximize,close";
      };
    };
  };
}
