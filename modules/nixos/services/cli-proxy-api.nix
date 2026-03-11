{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  cfg = config.custom.cli-proxy-api;
  svcPreStart = pkgs.writeShellScript "cli-proxy-api-pre-start" ''
    set -euo pipefail
    cfg="$STATE_DIRECTORY/config.yaml"
    ${pkgs.coreutils}/bin/mkdir -p "$STATE_DIRECTORY/auths"
    ${lib.getExe pkgs.yq-go} '.port = ${toString cfg.port}, .auth-dir = env(STATE_DIRECTORY) + "/auths"' "$cfg" > "$cfg.new"
    mv "$cfg.new" "$cfg"
  '';
in
{
  options.custom.cli-proxy-api = {
    enable = mkEnableOption "Enable CLI Proxy API service";

    package = mkPackageOption pkgs "cli-proxy-api" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8317;
      description = ''
        The TCP port which CLI Proxy API will listen on.
      '';
    };

    openFirewall = mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Opens the specified TCP port for CLI Proxy API.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cli-proxy-api ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.cli-proxy-api = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "CLI Proxy API instance";
      environment = {
        MANAGEMENT_STATIC_PATH = pkgs.cli-proxy-api-management-center;
      };
      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "cli-proxy-api";
        WorkingDirectory = "%S/cli-proxy-api";
        ExecStartPre = svcPreStart;
        ExecStart = ''
          ${lib.getExe pkgs.cli-proxy-api} -config config.yaml
        '';
      };
    };
  };
}
