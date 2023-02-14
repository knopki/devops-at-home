{ config, suites, lib, pkgs, ... }:
let
  defaultSopsFile = { format = "yaml"; sopsFile = ./secrets.yaml; };
in
{
  imports = suites.devbox ++ suites.mobile ++ suites.gamestation ++ [
    ./hardware-config.nix
    ./flatpak.nix
    ../../../users/sk
  ];

  environment = {
    systemPackages = with pkgs; [ tailscale wgcf ];
  };

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
        22000 # syncthing
      ];
      allowedTCPPortRanges = [
        { from = 6881; to = 6889; } # torrents
      ];
      allowedUDPPorts = [
        21027 # syncthing local discovery
        22000 # syncthing
      ];
      allowedUDPPortRanges = [
        { from = 6881; to = 6889; } # torrents
      ];
      trustedInterfaces = [ "ve-+" ];
    };
  };

  security.mitigations.acceptRisk = true;

  services = {
    tailscale.enable = true;

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
  };

  time.timeZone = "Europe/Moscow";

  users.users.root.passwordFile = config.sops.secrets.alien-root-user-password.path;
}
