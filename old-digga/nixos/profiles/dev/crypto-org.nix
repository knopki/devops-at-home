{
  config,
  pkgs,
  lib,
  ...
}: let
  dataDir = "/var/lib/cronosd";
  cassiniChainId = "cassini_339-1";
  cassiniDataDir = "${dataDir}/${cassiniChainId}";
  cassiniInit = pkgs.writeShellScriptBin "cassini-init" ''
    set -o pipefail
    DATA_DIR="${cassiniDataDir}/.cronos"
    if [ ! -d "$DATA_DIR" ]; then
      ${pkgs.cronosd}/bin/cronosd init knopki-node --chain-id ${cassiniChainId}
      rm $DATA_DIR/config/genesis.json
      ${pkgs.curl}/bin/curl https://raw.githubusercontent.com/crypto-org-chain/cassini/main/cassini-network-info/genesis.json > $DATA_DIR/config/genesis.json
    fi
    sed -i.bak -E 's#^(minimum-gas-prices[[:space:]]+=[[:space:]]+).*$#\1"5000000000000basetcro"#' $DATA_DIR/config/app.toml
    # sed -i.bak -E 's#^(persistent_peers[[:space:]]+=[[:space:]]+).*$#\1"a4a244577f98336a299b13a0d6ecab4188d3a259@13.214.93.59:26656,488a7324154c07ba4fe508642e019a88ecfa482f@3.67.15.54:26656"#' $DATA_DIR/config/config.toml
    sed -i.bak -E 's#^(create_empty_blocks_interval[[:space:]]+=[[:space:]]+).*$#\1"5s"#' $DATA_DIR/config/config.toml
    sed -i.bak -E 's#^(timeout_commit[[:space:]]+=[[:space:]]+).*$#\1"5s"#' $DATA_DIR/config/config.toml
  '';
in {
  environment.systemPackages = with pkgs; [
    curl
    cronosd
  ];

  networking.firewall.allowedTCPPorts = [26656];

  systemd.services.cronosd-cassini = {
    description = "Cassini testnet Cronosd";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = "cronosd-cassini";
      Group = "cronosd-cassini";
      Restart = "on-failure";
      LimitNOFILE = 65536;
      ExecStartPre = "${cassiniInit}/bin/cassini-init";
      ExecStart = ''
        ${pkgs.cronosd}/bin/cronosd start --log_level warn
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d '${cassiniDataDir}' 0770 'cronosd-cassini' 'cronosd-cassini' - -"
  ];

  users.users = {
    cronosd-cassini = {
      name = "cronosd-cassini";
      group = "cronosd-cassini";
      description = "Cassini testnet cronosd user";
      home = cassiniDataDir;
      isSystemUser = true;
    };
  };

  users.groups = {
    cronosd-cassini = {};
  };
}
