{ config, ... }:
let
  inherit (builtins) toString;
  lampaWebPort = 9118;
  lampacDataVol = "/var/lib/lampac";
in
{
  virtualisation.oci-containers.containers = {
    # how to configure:
    #   podman run --rm -it \
    #     -v /var/lib/isponsorblocktv:/app/data \
    #     ghcr.io/dmunozv04/isponsorblocktv:v2.6.0 --setup
    isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv:v2.6.0";
      volumes = [ "/var/lib/isponsorblocktv:/app/data" ];
    };

    lampac = {
      image = "dockerhub.timeweb.cloud/immisterio/lampac@sha256:6b7e862f2f20f17d20ddaed4095e5eccca7c53936ae5880367abb0c4b69e44ec"; # 2025-11-20
      environment = {
        TZ = "Europe/Moscow";
      };
      ports = [
        "${toString lampaWebPort}:9118"
      ];
      volumes = [
        "${config.sops.secrets.lampa-admin-password.path}:/home/passwd"
        "${lampacDataVol}/init.conf:/home/init.conf"
        "${lampacDataVol}/users.json:/home/users.json"
        "${lampacDataVol}/database:/home/database"
        "${lampacDataVol}/cache:/home/cache"
        "${lampacDataVol}/dlna:/home/dlna"
        "${lampacDataVol}/module/manifest.json:/home/module/manifest.json"
        "${lampacDataVol}/module/JacRed.json:/home/module/JacRed.json"
        "${lampacDataVol}/torrserver/accs.db:/home/torrserver/accs.db"
        "${lampacDataVol}/torrserver/viewed.json:/home/torrserver/viewed.json"
        "${lampacDataVol}/torrserver/settings.json:/home/torrserver/settings.json"
        "${lampacDataVol}/torrserver/config.db:/home/torrserver/config.db"
        "${lampacDataVol}/plugins/privateinit.my.js:/home/plugins/privateinit.my.js"
        "${lampacDataVol}/wwwroot/lampa-main:/home/wwwroot/lampa-main"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    lampaWebPort
  ];

  sops.secrets.lampa-admin-password = { };
}
