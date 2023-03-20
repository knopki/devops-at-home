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
    variables = {
      PLASMA_USE_QT_SCALING = "1";
    };
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
    networkmanager.unmanaged = [ "azire1" ];
    search = [ "1984.run" "lan" ];
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
    azire1-wg-private-key = defaultSopsFile // {
      key = "azire1-wg-private-key";
      path = "/var/secrets/azire1-wg-private-key";
      owner = config.users.users.systemd-network.name;
      group = config.users.groups.systemd-network.name;
      mode = "0640";
      reloadUnits = [ "systemd-networkd.service" ];
    };
  };

  system.stateVersion = "20.09";

  systemd = {
    network = {
      config.routeTables = {
        azire = 42;
      };
      netdevs = {
        azire1 = {
          netdevConfig = {
            Name = "azire1";
            Kind = "wireguard";
            MTUBytes = "1420";
          };
          wireguardConfig = {
            PrivateKeyFile = config.sops.secrets.azire1-wg-private-key.path;
          };
          wireguardPeers = [
            {
              wireguardPeerConfig = {
                AllowedIPs = [ "0.0.0.0/0" "::/0" ];
                Endpoint = "nl-ams.azirevpn.net:51820";
                PersistentKeepalive = 15;
                PublicKey = "W+LE+uFRyMRdYFCf7Jw0OPERNd1bcIm0gTKf/traIUk=";
              };
            }
          ];
        };
      };
      networks = {
        azire1 = {
          enable = true;
          name = "azire1";
          address = [ "10.0.0.14/32" "2a0e:1c80:1337:1:10:0:0:14/128" ];
          networkConfig = { IPForward = "ipv4"; };
          routes = [
            { routeConfig = { Destination = "0.0.0.0/0"; Table = "azire"; MTUBytes = "1420"; }; }
          ];
          routingPolicyRules = [
            { routingPolicyRuleConfig = { IncomingInterface = "virbr1"; Table = "azire"; Priority = 1000; }; }
          ];
        };
      };
      wait-online = {
        anyInterface = true;
        extraArgs = [ "-i" "enp59s0" "-i" "wlp60s0" ];
      };
    };
    services = {
      systemd-networkd = {
        serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
      };
    };
    # services.NetworkManager-wait-online.enable = false;
  };

  time.timeZone = "Europe/Moscow";
  users.users.root.passwordFile = config.sops.secrets.alien-root-user-password.path;
}
