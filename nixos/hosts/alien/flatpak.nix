{ config, lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep stringAfter;
  inherit (lib.generators) toINI;
  inherit (pkgs) writeTextDir;
  flathub_apps = [
    "chat.delta.desktop"
    "chat.rocket.RocketChat"
    "com.bitwarden.desktop"
    "com.discordapp.Discord"
    "com.github.AlizaMedicalImaging.AlizaMS"
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
    "org.freedesktop.Sdk.Extension.texlive//22.08" # required by pandoc in obsidian
    "org.gtk.Gtk3theme.Arc-Dark"
    "org.inkscape.Inkscape"
    "org.kde.KStyle.Kvantum//5.15"
    "org.kde.KStyle.Kvantum//5.15-21.08"
    "org.kde.KStyle.Kvantum//5.15-22.08"
    "org.kde.digikam"
    "org.kde.kdenlive"
    "org.kde.krita"
    "org.libreoffice.LibreOffice"
    "org.musicbrainz.Picard"
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
          sockets = "!x11;!fallback-x11;!wayland;!cups;!gpg-agent;!pcsc;!ssh-auth;!session-bus;!system-bus;";
          shared = "!ipc;!network;";
          features = "!bluetooth;!devel;!multiarch;!canbus;!per-app-dev-shm;";
          devices = "!dri;!kvm;!shm;!all;";
          filesystems = "!host;!host-etc;!host-os;!home;!xdg-desktop;!xdg-documents;!xdg-download;!xdg-music;!xdg-pictures;!xdg-public-share;!xdg-videos;!xdg-templates;!xdg-config;!xdg-cache;!xdg-data;!xdg-run/keyring;!/media;!/run/media;!/tmp";
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
      name = "com.github.tchx84.Flatseal";
      text = toINI { } {
        Context = {
          shared = "ipc;";
          sockets = "wayland;fallback-x11;";
          devices = "dri;";
          filesystems = "xdg-data/flatpak/overrides:create;/var/lib/flatpak/app:ro;xdg-data/flatpak/app:ro;";
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
          filesystems = "host:ro;xdg-download;xdg-pictures;xdg-videos;/media:ro;/run/media:ro;/tmp;";
        };
      };
    }
    {
      name = "md.obsidian.Obsidian";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;";
          shared = "network;ipc;ssh-auth;";
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
          filesystems = "xdg-desktop;xdg-download;xdg-pictures;xdg-videos;/media;/run/media;";
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
      name = "org.kde.digikam";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;fallback-x11;cups;";
          shared = "ipc;";
          devices = "dri;";
          filesystems = "xdg-desktop;xdg-download;xdg-pictures;xdg-videos;/media;/run/media;";
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
          filesystems = "xdg-desktop;xdg-download;xdg-pictures;xdg-videos;/media;/run/media;";
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
      name = "org.remmina.Remmina";
      text = toINI { } {
        Context = {
          sockets = "x11;wayland;fallback-x11;ssh-auth;pcsc;cups;";
          shared = "network;ipc;";
          devices = "all;";
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
          filesystems = "host:ro;xdg-download;xdg-pictures;xdg-videos;/media:ro;/run/media:ro;/tmp;";
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
in
{
  environment.shellAliases = {
    mpv = "io.mpv.Mpv";
    vlc = "org.videolan.VLC";
  };

  system.activationScripts.makeFlatpakOverrides = stringAfter [ "var" ] ''
    mkdir -p /var/lib/flatpak/overrides
    ${pkgs.findutils}/bin/find /var/lib/flatpak/overrides -mindepth 1 -delete
    ${concatStringsSep "\n"
      (map (x: "cp -f ${x}/* /var/lib/flatpak/overrides/") flatpak_overrides)}
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
          # add repos
          ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
          ${flathub_cmd}
          ${pkgs.flatpak}/bin/flatpak uninstall --system --unused -y --noninteractive

          # discord/openasar
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
