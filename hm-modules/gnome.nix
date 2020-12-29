{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.gnome = {
    enable = mkEnableOption "setup gnome";
  };

  config = mkIf config.knopki.gnome.enable {
    home.packages = with pkgs; [ gnome3.rhythmbox ];

    home.file = {
      "${config.xdg.configHome}/gtk-3.0/bookmarks".text = ''
        file://${config.home.homeDirectory}/dev Development
        file://${config.home.homeDirectory}/docs Documents
        file://${config.home.homeDirectory}/downloads Downloads
        file://${config.home.homeDirectory}/music Music
        file://${config.home.homeDirectory}/pics Pictures
        file://${config.home.homeDirectory}/videos Videos
        file://${config.home.homeDirectory}/library Library
        file://${config.home.homeDirectory}/trash Trash
      '';
    };

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
          font-name = config.gtk.gtk3.extraConfig.gtk-font-name;
          gtk-theme = config.gtk.gtk3.extraConfig.gtk-theme-name;
          cursor-theme = config.gtk.gtk3.extraConfig.gtk-cursor-theme-name;
          icon-theme = config.gtk.gtk3.extraConfig.gtk-icon-theme-name;
        };

        "org/gnome/desktop/peripherals/touchpad" = { natural-scroll = false; };

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
        gtk-font-name = config.gtk.font.name;
        gtk-theme-name = "Adwaita-dark";
        gtk-cursor-theme-name = "Adwaita";
        gtk-icon-theme-name = "Adwaita";
        gtk-fallback-icon-theme = "hicolor";
        gtk-application-prefer-dark-theme = 0;
        gtk-button-images = 1;
        gtk-enable-primary-paste = 1;
        gtk-menu-images = 1;
        gtk-primary-button-warps-slider = 0;
      };
    };

    systemd.user.sessionVariables = {
      # CLUTTER_BACKEND = "wayland";
      # GDK_BACKEND = "wayland";
      GTK_RC_FILES = "${config.xdg.configHome}/gtk-1.0/gtkrc";
      GTK2_RC_FILES = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };
  };
}
