{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.gnome = {
    enable = mkEnableOption "setup gnome";
    mime = mkEnableOption "gnome file associations";
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
          cursor-theme = "Adwaita";
          gtk-theme = "Adwaita-dark";
          icon-theme = "Adwaita";
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
        gtk-application-prefer-dark-theme = 0;
        gtk-button-images = 1;
        gtk-enable-primary-paste = 1;
        gtk-fallback-icon-theme = "hicolor";
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

    xdg.mimeApps = mkIf config.knopki.gnome.mime {
      enable = true;
      defaultApplications = (
        listToAttrs (
          map (x: nameValuePair x "eog.desktop") [
            "image/bmp"
            "image/gif"
            "image/jpeg"
            "image/jpg"
            "image/pjpeg"
            "image/png"
            "image/svg+xml"
            "image/svg+xml-compressed"
            "image/tiff"
            "image/vnd.wap.wbmp"
            "image/x-bmp"
            "image/x-gray"
            "image/x-icb"
            "image/x-icns"
            "image/x-ico"
            "image/x-pcx"
            "image/x-png"
            "image/x-portable-anymap"
            "image/x-portable-bitmap"
            "image/x-portable-graymap"
            "image/x-portable-pixmap"
            "image/x-xbitmap"
            "image/x-xpixmap"
          ]
        )
      ) // {
        "x-scheme-handler/mailto" = "org.gnome.Geary.desktop";
      };
    };
  };
}
