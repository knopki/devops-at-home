{
  config,
  lib,
  pkgs,
  self,
  packages,
  ...
}:
let
  inherit (lib) mkDefault mkIf;
in
{
  imports = with self.modules.homeManager; [
    legacy-kde
  ];

  home.packages =
    with pkgs;
    with plasma5Packages;
    with plasma5;
    with kdeApplications;
    with kdeFrameworks;
    [
      dconf
      plasma-applet-caffeine-plus
      plasma-applet-virtual-desktop-bar
    ];

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

  programs = {
    alacritty = {
      enable = mkDefault true;
      settings = {
        key_bindings = [
          # spawn a new instance of Alacritty in the current working directory
          {
            key = "Return";
            mods = "Control|Shift";
            action = "SpawnNewInstance";
          }
        ];
        window = {
          opacity = 0.95;
        };
      };
    };

    brave = {
      enable = lib.mkDefault true;
      package = pkgs.brave;
    };

    firefox = {
      enable = mkDefault true;

      package = packages.firefox;

      profiles = {
        default = {
          id = 0;
          name = "default";
          isDefault = mkDefault true;
          settings = {
            "browser.cache.disk.capacity" = mkDefault 128000;
            "browser.safebrowsing.allowOverride" = mkDefault false;
            "browser.safebrowsing.blockedURIs.enabled" = mkDefault false;
            "browser.safebrowsing.downloads.enabled" = mkDefault false;
            "browser.safebrowsing.downloads.remote.block_dangerous" = mkDefault false;
            "browser.safebrowsing.downloads.remote.block_dangerous_host" = mkDefault false;
            "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = mkDefault false;
            "browser.safebrowsing.downloads.remote.block_uncommon" = mkDefault false;
            "browser.safebrowsing.downloads.remote.enabled" = mkDefault false;
            "browser.safebrowsing.malware.enabled" = mkDefault false;
            "browser.safebrowsing.phishing.enabled" = mkDefault false;
            "browser.search.suggest.enabled" = mkDefault true;
            "browser.startup.page" = mkDefault 3;
            "extensions.pocket.enabled" = mkDefault false;
            "media.peerconnection.enabled" = mkDefault false;
            "network.security.esni.enabled" = mkDefault true;
            "network.trr.mode" = mkDefault 2; # prefer DNS-over-HTTPS
            "privacy.resistFingerprinting" = mkDefault true;
            "privacy.trackingprotection.cryptomining.enabled" = mkDefault true;
            "privacy.trackingprotection.fingerprinting.enabled" = mkDefault true;
          };
        };
      };
    };

    imv = {
      enable = lib.mkDefault true;
      settings = {
        binds = {
          "<Shift+Left>" = "prev 10";
          "<Shift+Right>" = "next 10";
        };
      };
    };

    zathura = {
      enable = lib.mkDefault true;
      options = {
        selection-clipboard = "clipboard";
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

  systemd.user.targets.tray = mkIf config.programs.kde.enable {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  xdg.mimeApps = {
    associations.added = {
      "application/epub+zip" = [ "org.pwmt.zathura.desktop" ];
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    };
  };
}
