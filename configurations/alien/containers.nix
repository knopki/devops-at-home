{ config, ... }:
let
  inherit (builtins) toString;
  lampaWebPort = 9118;
  lampaTorrservePort = 9080;
  lampaTorrservePeersPort = 16881;
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
      image = "dockerhub.timeweb.cloud/immisterio/lampac@sha256:6b1e63337922b3485f35aaa86702bf5ca82f9a0a2cc8c31594d39feb676087a1"; # 2025-12-23
      environment = {
        TZ = "Europe/Moscow";
      };
      ports = [
        "${toString lampaWebPort}:9118"
        "${toString lampaTorrservePort}:9080"
        "${toString lampaTorrservePeersPort}:16881"
      ];
      volumes = [
        "${config.sops.secrets.lampa-admin-password.path}:/home/passwd:ro"
        "${lampacDataVol}/init.conf:/home/init.conf"
        "${lampacDataVol}/users.json:/home/users.json"
        "${lampacDataVol}/database:/home/database"
        "${lampacDataVol}/cache:/home/cache"
        "${lampacDataVol}/dlna:/home/dlna"
        "${lampacDataVol}/module/manifest.json:/home/module/manifest.json"
        "${lampacDataVol}/module/JacRed.json:/home/module/JacRed.current.json"
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
    lampaTorrservePeersPort
  ];

  sops.secrets.lampa-admin-password = { };
}
