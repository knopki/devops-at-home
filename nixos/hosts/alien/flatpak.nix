{ config, lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep stringAfter;
  inherit (lib.generators) toINI;
  inherit (pkgs) writeTextDir symlinkJoin;
  flathub_apps = [
    "chat.delta.desktop"
    "chat.rocket.RocketChat"
    "com.bitwarden.desktop"
    "com.discordapp.Discord"
    "com.github.AlizaMedicalImaging.AlizaMS"
    "com.github.micahflee.torbrowser-launcher"
    "com.github.tchx84.Flatseal"
    "com.logseq.Logseq"
    "com.obsproject.Studio"
    "com.skype.Client"
    "com.spotify.Client"
    "com.usebottles.bottles"
    "im.riot.Riot"
    "io.mpv.Mpv"
    "md.obsidian.Obsidian"
    "net.ankiweb.Anki"
    "org.briarproject.Briar"
    "org.darktable.Darktable"
    "org.freedesktop.Platform.Icontheme.Adwaita"
    "org.freedesktop.Sdk.Extension.texlive//22.08" # required by pandoc in obsidian
    "org.gtk.Gtk3theme.Arc-Dark"
    "org.inkscape.Inkscape"
    "org.kde.KStyle.Adwaita/x86_64/6.4"
    "org.kde.KStyle.Kvantum//5.15"
    "org.kde.KStyle.Kvantum//5.15-21.08"
    "org.kde.KStyle.Kvantum//5.15-22.08"
    "org.kde.PlatformTheme.QGnomePlatform/x86_64/6.4"
    "org.kde.ark"
    "org.kde.digikam"
    "org.kde.gwenview"
    "org.kde.kdenlive"
    "org.kde.krita"
    "org.kde.okular"
    "org.keepassxc.KeePassXC"
    "org.libreoffice.LibreOffice"
    "org.musicbrainz.Picard"
    "org.qbittorrent.qBittorrent"
    "org.remmina.Remmina"
    "org.telegram.desktop"
    "org.videolan.VLC"
    "us.zoom.Zoom"
  ];
  flatpak_overrides = map (x: writeTextDir x.name x.text) [
    {
      name = "global";
      text = toINI { } {
        Context = {
          sockets = concatStringsSep ";" [
            "!x11"
            "!fallback-x11"
            "!wayland"
            "!cups"
            "!gpg-agent"
            "!pcsc"
            "!ssh-auth"
            "!session-bus"
            "!system-bus"
            ""
          ];
          shared = "!ipc;!network;";
          features = "!bluetooth;!devel;!multiarch;!canbus;!per-app-dev-shm;";
          devices = "!dri;!kvm;!shm;!all;";
          filesystems = concatStringsSep ";" [
            "!host"
            "!host-etc"
            "!host-os"
            "!home"
            "!xdg-cache"
            "!xdg-config"
            "!xdg-data"
            "!xdg-desktop"
            "!xdg-documents"
            "!xdg-download"
            "!xdg-music"
            "!xdg-pictures"
            "!xdg-public-share"
            "!xdg-templates"
            "!xdg-videos"
            "!xdg-run/keyring"
            "!/media"
            "!/run/media"
            "!/tmp"
            "xdg-config/Kvantum:ro"
            "xdg-config/kdeglobals:ro"
            "xdg-config/gtk-3.0:ro"
            "xdg-config/gtk-4.0:ro"
            ""
          ];
        };
        Environment = {
          QT_STYLE_OVERRIDE = "kvantum";
        };
        "System Bus Policy" = {
          "org.freedesktop.Accounts" = "none";
          "org.freedesktop.systemd1" = "none";
          "org.freedesktop.secrets" = "none";
          "org.freedesktop.impl.portal.PermissionStore" = "none";
        };
        "Session Bus Policy" = {
          "org.freedesktop.Flatpak" = "none";
        };
      };
    }
    {
      name = "chat.delta.desktop";
      text = toINI { } {
        Context = {
          shared = "network;ipc;";
          sockets = "x11;";
          devices = "dri";
          filesystems = "xdg-documents:ro;xdg-download;xdg-pictures:ro;";
        };
      };
    }
    {
      name = "chat.rocket.RocketChat";
      text = toINI { } {
        Context = {
          shared = "network;ipc;";
          sockets = "wayland;fallback-x11;";
          devices = "dri;";
          filesystems = "xdg-download;";
        };
      };
    }
    {
      name = "com.bitwarden.desktop";
      text = toINI { } {
        Context = {
          shared = "network;ipc;";
          sockets = "wayland;fallback-x11;";
          devices = "dri";
          filesystems = "xdg-download;";
        };
        "System Bus Policy" = {
          "org.freedesktop.secrets" = "talk";
        };
      };
    }
    {
      name = "com.discordapp.Discord";
      text = toINI { } {
        Context = {
          shared = "network;ipc;";
          sockets = "wayland;fallback-x11;";
          filesystems = "xdg-download;";
        };
      };
    }
    {
      name = "com.github.AlizaMedicalImaging.AlizaMS";
      text = toINI { } {
        Context = {
          shared = "ipc;";
          sockets = "x11;";
          devices = "dri;";
          filesystems = "xdg-documents:ro;xdg-download;";
        };
      };
    }
    {
      name = "com.github.micahflee.torbrowser-launcher";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;fallback-x11;";
          shared = "ipc;network;";
          devices = "dri;";
          filesystems = "xdg-download;";
        };
      };
    }
    {
      name = "com.github.tchx84.Flatseal";
      text = toINI { } {
        Context = {
          shared = "ipc;";
          sockets = "wayland;fallback-x11;";
          devices = "dri;";
          filesystems = concatStringsSep ";" [
            "xdg-data/flatpak/overrides:create"
            "xdg-data/flatpak/app:ro"
            "/var/lib/flatpak/app:ro"
            ""
          ];
        };
        "System Bus Policy" = {
          "org.freedesktop.impl.portal.PermissionStore" = "talk";
        };
      };
    }
    {
      name = "com.logseq.Logseq";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;cups;";
          shared = "network;ipc;";
          devices = "dri;";
          filesystems = "xdg-documents;";
          persistent = ".logseq;";
        };
      };
    }
    {
      name = "com.obsproject.Studio";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "network;ipc;";
          devices = "all;";
          filesystems = "xdg-desktop;xdg-download;xdg-pictures;xdg-videos;";
        };
        "Session Bus Policy" = {
          "org.freedesktop.Flatpak" = "talk"; # why?
        };
      };
    }
    {
      name = "com.skype.Client";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "network;ipc;";
          devices = "all;"; # bad?
          filesystems = "xdg-download;";
        };
        "Session Bus Policy" = {
          "org.freedesktop.secrets" = "talk";
        };
      };
    }
    {
      name = "com.spotify.Client";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "network;ipc;";
          devices = "dri";
          filesystems = "xdg-music:ro;";
        };
      };
    }
    {
      name = "com.usebottles.bottles";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "network;ipc;";
          devices = "all;";
          features = "devel;multiarch;";
          filesystems = "xdg-download;xdg-data/applications;";
        };
      };
    }
    {
      name = "im.riot.Riot";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "network;ipc;";
          devices = "all;";
          filesystems = "xdg-download;xdg-run/keyring;";
        };
      };
    }
    {
      name = "io.mpv.Mpv";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "network;ipc;";
          devices = "dri;all;";
          filesystems = concatStringsSep ";" [
            "host:ro"
            "xdg-download"
            "xdg-pictures"
            "xdg-videos"
            "/media:ro"
            "/run/media:ro"
            "/tmp"
            ""
          ];
        };
      };
    }
    {
      name = "md.obsidian.Obsidian";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;ssh-auth;";
          shared = "network;ipc;";
          devices = "dri;";
          filesystems = "xdg-documents;xdg-download;xdg-run/keyring;home/.ssh";
        };
        Environment = {
          OBSIDIAN_DISABLE_GPU = "0";
        };
      };
    }
    {
      name = "net.ankiweb.Anki";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "network;ipc;";
          devices = "dri;";
        };
      };
    }
    {
      name = "org.briarproject.Briar";
      text = toINI { } {
        Context = {
          sockets = "x11;";
          shared = "network;ipc;";
          devices = "dri;";
          filesystems = "xdg-download;";
        };
      };
    }
    {
      name = "org.darktable.Darktable";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "ipc;";
          filesystems = concatStringsSep ";" [
            "xdg-desktop"
            "xdg-download"
            "xdg-pictures"
            "xdg-videos"
            "/media"
            "/run/media"
          ];
        };
        "System Bus Policy" = {
          "org.freedesktop.secrets" = "talk";
        };
      };
    }
    {
      name = "org.inkscape.Inkscape";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "ipc;";
          filesystems = "xdg-desktop;xdg-download;xdg-pictures;";
        };
      };
    }
    {
      name = "org.kde.ark";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "ipc;";
          devices = "dri;";
          filesystems = concatStringsSep ";" [
            "home"
            "/media"
            "/run/media"
          ];
        };
      };
    }
    {
      name = "org.kde.digikam";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;fallback-x11;cups;";
          shared = "ipc;";
          devices = "dri;";
          filesystems = concatStringsSep ";" [
            "xdg-desktop"
            "xdg-download"
            "xdg-pictures"
            "xdg-videos"
            "/media"
            "/run/media"
          ];
        };
      };
    }
    {
      name = "org.kde.gwenview";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;fallback-x11;";
          shared = "ipc;";
          devices = "dri;";
          filesystems = concatStringsSep ";" [
            "home:ro"
            "/media:ro"
            "/run/media:ro"
          ];
        };
      };
    }
    {
      name = "org.kde.kdenlive";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "ipc;";
          devices = "dri;";
          filesystems = concatStringsSep ";" [
            "xdg-desktop"
            "xdg-download"
            "xdg-pictures"
            "xdg-videos"
            "/media"
            "/run/media"
          ];
        };
      };
    }
    {
      name = "org.kde.krita";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "ipc;";
          devices = "dri;";
          filesystems = "xdg-desktop;xdg-download;xdg-pictures;";
        };
      };
    }
    {
      name = "org.kde.okular";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;fallback-x11;cups;";
          shared = "ipc;";
          devices = "dri;";
          filesystems = concatStringsSep ";" [
            "home:ro"
            "xdg-desktop"
            "xdg-documents"
            "xdg-download"
            "/media"
            "/run/media"
          ];
        };
      };
    }
    {
      name = "org.keepassxc.KeePassXC";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;ssh-auth;";
          shared = "ipc;";
          devices = "dri;";
          filesystems = "xdg-desktop;xdg-documents;xdg-download;;";
        };
      };
    }
    {
      name = "org.libreoffice.LibreOffice";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;fallback-x11;";
          shared = "ipc;";
          devices = "dri;";
          filesystems = "xdg-desktop;xdg-documents;xdg-download;";
        };
      };
    }
    {
      name = "org.musicbrainz.Picard";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "network;ipc;";
          filesystems = "xdg-music;xdg-download;/tmp;";
        };
      };
    }
    {
      name = "org.qbittorrent.qBittorrent";
      text = toINI { } {
        Context = {
          sockets = "wayland;fallback-x11;";
          shared = "network;ipc;";
          devices = "dri;";
          filesystems = "xdg-download;/media;/run/media;";
        };
      };
    }
    {
      name = "org.remmina.Remmina";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;fallback-x11;ssh-auth;pcsc;cups;";
          shared = "network;ipc;";
          devices = "dri;all;";
          filesystems = "xdg-download;";
        };
        "System Bus Policy" = {
          "org.freedesktop.secrets" = "talk";
        };
      };
    }
    {
      name = "org.telegram.desktop";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;fallback-x11;";
          shared = "network;ipc;";
          devices = "all;";
          filesystems = "xdg-download;";
        };
      };
    }
    {
      name = "org.videolan.VLC";
      text = toINI { } {
        Context = {
          sockets = "x11;";
          shared = "network;ipc;";
          devices = "dri;all;";
          filesystems = concatStringsSep ";" [
            "host:ro"
            "xdg-download"
            "xdg-pictures"
            "xdg-videos"
            "/media:ro"
            "/run/media:ro"
            "/tmp"
          ];
        };
        "System Bus Policy" = {
          "org.freedesktop.secrets" = "talk";
        };
      };
    }
    {
      name = "us.zoom.Zoom";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "network;ipc;";
          devices = "all;";
          filesystems = "xdg-download;!~/Documents/Zoom;!~/.zoom";
          persistent = ".zoom";
        };
      };
    }
  ];
  flatpak_all_overrides = symlinkJoin {
    name = "flatpak_overrides";
    paths = flatpak_overrides;
  };
in
{
  environment.shellAliases = {
    ffmpeg = "flatpak run --command=ffmpeg io.mpv.Mpv";
    mpv = "io.mpv.Mpv";
    vlc = "org.videolan.VLC";
  };

  system.activationScripts.makeFlatpakOverrides = stringAfter [ "var" ] ''
    mkdir -p /var/lib/flatpak
    rm -rf /var/lib/flatpak/overrides
    ln -s ${flatpak_all_overrides} /var/lib/flatpak/overrides
  '';

  systemd = {
    services.flatpak-setup = {
      description = "Setup system Flatpak";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "graphical.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };
      script =
        let
          flathub_cmd = concatStringsSep "\n"
            (map
              (x: "${pkgs.flatpak}/bin/flatpak install flathub ${x} -y --noninteractive")
              flathub_apps);
        in
        ''
          ${pkgs.flatpak}/bin/flatpak config --system --set languages "en;ru"
          # add repos
          ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
          ${flathub_cmd}
          ${pkgs.flatpak}/bin/flatpak uninstall --system --unused -y --noninteractive

          # discord/openasar
          ${pkgs.flatpak}/bin/flatpak mask --system com.discordapp.Discord
          DISCOSAR=/var/lib/flatpak/app/com.discordapp.Discord/current/active/files/discord/resources/app.asar
          if [ -f "$DISCOSAR" ]; then
            DISCOSARSIZE=$(stat -c%s "$DISCOSAR")
            if (( DISCOSARSIZE > 1000000 )); then
              ${pkgs.curl}/bin/curl https://github.com/GooseMod/OpenAsar/releases/download/nightly/app.asar > "$DISCOSAR"
            fi
          fi
        '';
    };
  };

}
