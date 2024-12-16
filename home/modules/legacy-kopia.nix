{
  config,
  lib,
  pkgs,
  packages,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    mapAttrs'
    mapAttrsToList
    nameValuePair
    concatStringsSep
    escapeShellArg
    ;
  cfg = config.services.kopia;
  jobModule = types.submodule (
    { config, ... }:
    {
      options = {
        snapshots = mkOption {
          type = with types; listOf str;
          description = "List of snapshots";
        };
        timer = mkOption {
          type = with types; attrsOf str;
          description = "Attrs of systemd Timer section";
        };
        args = mkOption {
          type = with types; listOf str;
          default = [ ];
          description = "List of optional arguments";
        };
      };
    }
  );
in
{
  options.services.kopia = {
    enable = mkEnableOption "kopia configuration";
    jobs = mkOption {
      type = types.attrsOf jobModule;
      default = { };
      description = "Kopia jobs";
    };
    env = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = "Kopia unit files environment variables";
    };
    envFile = mkOption {
      type = with types; str;
      default = null;
      description = "Kopia unit files environment variables in file";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ packages.kopia ];

    systemd.user.services = mapAttrs' (
      name: value:
      nameValuePair "kopia-${name}" {
        Unit = {
          Description = "Kopia sync - ${name}";
          StartLimitIntervalSec = "0";
          After = mkIf (builtins.hasAttr "sops" config) [ "sops-nix.service" ];
        };
        Service = {
          CPUSchedulingPolicy = "idle";
          IOSchedulingClass = "idle";
          Restart = "on-failure";
          RestartSec = "1m";
          Type = "oneshot";
          Environment = mapAttrsToList (name: value: "${name}=${value}") cfg.env;
          EnvironmentFile = mkIf (cfg.envFile != null) cfg.envFile;
          WorkingDirectory = "/run/user/%U";
          ExecStart = concatStringsSep " " (
            [
              "${pkgs.util-linux}/bin/flock kopia-service.lock"
              "${pkgs.kopia}/bin/kopia --password=$(cat $KOPIA_PASSWORD_FILE) snapshot create"
            ]
            ++ (map escapeShellArg value.args)
            ++ (map escapeShellArg value.snapshots)
          );
        };
      }
    ) cfg.jobs;

    systemd.user.timers = mapAttrs' (
      name: value:
      nameValuePair "kopia-${name}" {
        Unit = {
          Description = "Kopia periodic snapshotting - ${name}";
        };
        Timer = {
          Unit = "kopia-${name}.service";
          Persistent = true;
        } // value.timer;
        Install = {
          WantedBy = [ "timers.target" ];
        };
      }
    ) cfg.jobs;
  };
}
