{
  config,
  self,
  ...
}:
let
  lampaWebPort = 9118;
  lampaTorrservePort = 9080;
  lampaTorrservePeersPort = 16881;
  lampacDataVol = "/var/lib/lampac";
  hindsightApiPort = 8888;
  hindsightUiPort = 8889;
in
{
  imports = with self.modules.nixos; [
    service-cli-proxy-api
    service-isponsorblocktv
  ];

  custom.cli-proxy-api.enable = true;
  custom.isponsorblocktv.enable = true;

  virtualisation.oci-containers.containers = {
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

    hindsight-api = {
      image = "ghcr.io/vectorize-io/hindsight:0.4.22-slim";
      ports = [ "127.0.0.1:${toString hindsightApiPort}:8888" ];
      volumes = [ "/var/lib/hindsight-pg/_data:/home/hindsight/.pg0" ];
      environment = {
        HINDSIGHT_API_LLM_PROVIDER = "openai";
        HINDSIGHT_API_LLM_BASE_URL = "http://host.containers.internal:${toString config.custom.cli-proxy-api.port}/v1";
        HINDSIGHT_API_LLM_MODEL = "glm-4.7";
        HINDSIGHT_API_EMBEDDINGS_PROVIDER = "openai";
        HINDSIGHT_API_EMBEDDINGS_OPENAI_BASE_URL = "https://openrouter.ai/api/v1";
        HINDSIGHT_API_EMBEDDINGS_OPENAI_MODEL = "text-embedding-3-small";
        HINDSIGHT_API_RERANKER_PROVIDER = "rrf";
        HINDSIGHT_API_HOST = "0.0.0.0";
        HINDSIGHT_API_PORT = "8888";
      };
      environmentFiles = [ config.sops.secrets.hindsight-api-env.path ];
      extraOptions = [ "--add-host=host.containers.internal:host-gateway" ];
    };

    hindsight-ui = {
      image = "ghcr.io/vectorize-io/hindsight-control-plane:0.4.22";
      ports = [ "127.0.0.1:${toString hindsightUiPort}:9999" ];
      environment = {
        HINDSIGHT_CP_DATAPLANE_API_URL = "http://hindsight-api:8888";
      };
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
    hindsight-api-env = { };
  };
}
