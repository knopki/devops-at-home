{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) toString;

  torrserverPort = 5665;
in
{
  virtualisation.oci-containers.containers = {
    torrserver = {
      image = "ghcr.io/yourok/torrserver:MatriX.133t";
      environment = {
        TS_DONTKILL = "1";
        TS_HTTPAUTH = "0";
      };
      volumes = [
        "/var/lib/torrserver/torrents:/opt/ts/torrents"
        "/var/lib/torrserver/config:/opt/ts/config"
      ];
      ports = [ "${toString torrserverPort}:8090" ];
    };

    # how to configure:
    #   podman run --rm -it \
    #     -v /var/lib/isponsorblocktv:/app/data \
    #     ghcr.io/dmunozv04/isponsorblocktv:v2.2.1 --setup
    isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv:v2.2.1";
      volumes = [ "/var/lib/isponsorblocktv:/app/data" ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ torrserverPort ];
  };
}
