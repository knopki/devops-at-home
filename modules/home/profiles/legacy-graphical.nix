{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
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

  qt.kde.settings = {
    kdeglobals.KDE.SingleClick = mkDefault false;

    kxkbrc.Layout = {
      ResetOldOptions = mkDefault true;
      SwitchMode = mkDefault "Window";
      Use = mkDefault true;
    };

    spectaclerc = {
      General = {
        autoSaveImage = true;
        copyImageToClipboard = true;
        copySaveLocation = false;
      };
      Save = {
        defaultSaveLocation = "file://${config.xdg.userDirs.pictures}/screenshots/";
        saveFilenameFormat = "scrn-%Y%M%D-%H%m%S";
      };
    };
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  xdg.mimeApps = {
    associations.added = {
      "application/epub+zip" = [ "org.kde.okular.desktop" ];
      "application/pdf" = [ "org.kde.okular.desktop" ];
    };
  };
}
