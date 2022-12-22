{ config, suites, lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep stringAfter;
  inherit (lib.generators) toINI;
  inherit (pkgs) writeTextDir;
  defaultSopsFile = { format = "yaml"; sopsFile = ./secrets.yaml; };
  flathub_apps = [
    "chat.delta.desktop"
    "com.bitwarden.desktop"
    "com.discordapp.Discord"
    "com.github.AlizaMedicalImaging.AlizaMS"
    "com.github.tchx84.Flatseal"
    "com.logseq.Logseq"
    "com.spotify.Client"
    "com.usebottles.bottles"
    "md.obsidian.Obsidian"
    "net.ankiweb.Anki"
    "org.gtk.Gtk3theme.Arc-Dark"
    "org.inkscape.Inkscape"
    "org.kde.KStyle.Kvantum//5.15"
    "org.kde.KStyle.Kvantum//5.15-21.08"
    "org.kde.KStyle.Kvantum//5.15-22.08"
    "org.kde.krita"
    "org.remmina.Remmina"
    "org.telegram.desktop"
  ];
  flatpak_overrides = map (x: writeTextDir x.name x.text) [
    {
      name = "global";
      text = toINI {} {
        Context = {
          filesystems = "!host;!home;";
        };
      };
    }
    {
      name = "com.logseq.Logseq";
      text = toINI {} {
        Context = {
          filesystems = "xdg-config/Logseq;xdg-documents;home/.logseq;";
        };
      };
    }
    {
      name = "com.usebottles.bottles";
      text = toINI {} {
        Context = {
          filesystems = "xdg-data/applications;";
        };
      };
    }
    {
      name = "org.kde.krita";
      text = toINI {} {
        Context = {
          filesystems = "xdg-desktop;xdg-download;xdg-pictures;";
        };
      };
    }
    {
      name = "org.inkscape.Inkscape";
      text = toINI {} {
        Context = {
          filesystems = "xdg-desktop;xdg-download;xdg-pictures;";
        };
      };
    }
    {
      name = "com.spotify.Client";
      text = toINI {} {
        Context = {
          filesystems = "!xdg-pictures;";
        };
      };
    }
    {
      name = "com.discordapp.Discord";
      text = toINI {} {
        Context = {
          filesystems = "!xdg-pictures;";
        };
      };
    }
    {
      name = "com.github.AlizaMedicalImaging.AlizaMS";
      text = toINI {} {
        Context = {
          filesystems = "xdg-documents;";
        };
      };
    }
  ];
in
{
  imports = suites.devbox ++ suites.mobile ++ suites.gamestation ++ [
    ./hardware-config.nix
    ../../../users/sk
  ];

  networking = {
    hostId = "ff0b9d65";
    hosts = {
      "127.0.0.84" = [
        "adminer.xod.loc"
        "api.xod.loc"
        "auth.xod.loc"
        "billing-db.xod.loc"
        "billing.xod.loc"
        "compile.xod.loc"
        "compiler.xod.loc"
        "mail.xod.loc"
        "main-db.xod.loc"
        "mqtt.xod.loc"
        "neo4j.xod.loc"
        "pm.xod.loc"
        "releases.xod.loc"
        "rethinkdb.xod.loc"
        "s3.xod.loc"
        "swagger-ui.xod.loc"
        "xod.loc"
      ];
    };
    nat = {
      enable = true;
      externalInterface = "wlp60s0";
      internalInterfaces = [ "ve-+" ];
    };
    search = [ "1984.run" ];
    firewall = {
      allowedTCPPorts = [
        4001 # ipfs
        8010 # chromecast sharing port
        8080 # ipfs
        22000 # syncthing
      ];
      allowedUDPPorts = [
        4001 # ipfs
        21027 # syncthing local discovery
        22000 # syncthing
      ];
      trustedInterfaces = [ "ve-+" ];
    };
  };

  security.mitigations.acceptRisk = true;

  services = {
    kubo = {
      enable = true;
      autoMount = true;
      enableGC = true;
      localDiscovery = true;
      extraFlags = [ "--routing=dhtclient" ];
      settings = {
        Datastore.StorageMax = "1GB";
        Swarm.ConnMgr = {
          Type = "basic";
          LowWater = 20;
          HighWater = 40;
          GracePeriod = "1m0s";
        };
      };
      startWhenNeeded = true;
    };

    zerotierone = {
      enable = true;
      joinNetworks = [ "1c33c1ced08df9ac" "0cccb752f7043dce" ];
    };
  };

  sops.secrets = {
    alien-root-user-password = defaultSopsFile // {
      key = "root-user-password";
      path = "/var/secrets/root-user-password";
      neededForUsers = true;
    };
  };

  system.stateVersion = "20.09";

  system.activationScripts.makeFlatpakOverrides = stringAfter [ "var" ] ''
    mkdir -p /var/lib/flatpak/overrides
    ${pkgs.findutils}/bin/find /var/lib/flatpak/overrides -mindepth 1 -delete
    ${concatStringsSep "\n"
      (map (x: "cp -f ${x}/* /var/lib/flatpak/overrides/") flatpak_overrides)}
  '';

  systemd = {
    network.wait-online = {
      anyInterface = true;
      extraArgs = [ "-i" "enp59s0" "-i" "wlp60s0" ];
    };

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

  time.timeZone = "Europe/Moscow";

  users.users.root.passwordFile = config.sops.secrets.alien-root-user-password.path;
}
