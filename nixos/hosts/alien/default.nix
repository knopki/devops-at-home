{ config, suites, pkgs, ... }:
let
  defaultSopsFile = { format = "yaml"; sopsFile = ./secrets.yaml; };
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

  systemd = {
    network.wait-online = {
      anyInterface = true;
      extraArgs = [ "-i" "enp59s0" "-i" "wlp60s0" ];
    };

    services.flatpak-setup = {
      description = "Setup system Flatpak";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      partOf = [ "graphical-session.target" ];
      restartIfChanged = true;
      serviceConfig.Type = "oneshot";
      script = ''
        # add repos
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        # install themes
        ${pkgs.flatpak}/bin/flatpak install flathub org.gtk.Gtk3theme.Arc-Dark -y --noninteractive
        ${pkgs.flatpak}/bin/flatpak install flathub org.kde.KStyle.Kvantum//5.15 -y --noninteractive
        ${pkgs.flatpak}/bin/flatpak install flathub org.kde.KStyle.Kvantum//5.15-21.08 -y --noninteractive
        ${pkgs.flatpak}/bin/flatpak install flathub org.kde.KStyle.Kvantum//5.15-22.08 -y --noninteractive

        # install apps
        ${pkgs.flatpak}/bin/flatpak install flathub com.github.tchx84.Flatseal -y --noninteractive
        ${pkgs.flatpak}/bin/flatpak install flathub org.telegram.desktop -y --noninteractive
        ${pkgs.flatpak}/bin/flatpak install flathub com.logseq.Logseq -y --noninteractive
        ${pkgs.flatpak}/bin/flatpak install flathub md.obsidian.Obsidian -y --noninteractive
      '';
    };
  };

  time.timeZone = "Europe/Moscow";

  users.users.root.passwordFile = config.sops.secrets.alien-root-user-password.path;
}
