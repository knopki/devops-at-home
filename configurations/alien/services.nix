{ config, ... }:
let
  lampaWebPort = 9118;
  lampaTorrservePort = 9080;
  lampaTorrservePeersPort = 16881;
  lampacDataVol = "/var/lib/lampac";
in
{
  virtualisation.oci-containers.containers = {
    cpa = {
      image = "dockerhub.timeweb.cloud/eceasy/cli-proxy-api:v7.2.115";
      ports = [ "127.0.0.1:8317:8317" ];
      volumes = [
        "/var/lib/cliproxyapi/config.yaml:/CLIProxyAPI/config.yaml"
        "/var/lib/cliproxyapi/logs:/CLIProxyAPI/logs"
        "/var/lib/cliproxyapi/plugins:/CLIProxyAPI/plugins"
        "/var/lib/cliproxyapi/auths:/root/.cli-proxy-api"
      ];
    };

    cpa-manager-plus = {
      image = "dockerhub.timeweb.cloud/seakee/cpa-manager-plus:v1.11.11";
      ports = [ "127.0.0.1:18317:18317" ];
      volumes = [ "/var/lib/cliproxyapi-manager-plus:/data" ];
    };

    isponsorblocktv = {
      image = "dockerhub.timeweb.cloud/dmunozv04/isponsorblocktv:v2.10";
      volumes = [
        "/var/lib/isponsorblocktv:/app/data"
      ];
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

  services = {
    taskchampion-sync-server = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
    };
  };

  sops.secrets = {
    lampa-admin-password = { };
  };
}
