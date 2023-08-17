{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
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
  jobModule = types.submodule ({config, ...}: {
    options = {
      snapshots = mkOption {
        type = with types; listOf str;
        description = "List of snapshots";
      };
      timer = mkOption {
        type = with types; attrsOf str;
        description = "Attrs of systemd Timer section";
      };
    };
  });
in {
  options.services.kopia = {
    enable = mkEnableOption "kopia configuration";
    jobs = mkOption {
      type = types.attrsOf jobModule;
      default = {};
      description = "Kopia jobs";
    };
    env = mkOption {
      type = with types; attrsOf str;
      default = {};
      description = "Kopia unit files environment variables";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [kopia];

    systemd.user.services =
      mapAttrs'
      (name: value:
        nameValuePair "kopia-${name}" {
          Unit = {
            Description = "Kopia sync - ${name}";
            StartLimitIntervalSec = "0";
          };
          Service = {
            CPUSchedulingPolicy = "idle";
            IOSchedulingClass = "idle";
            Restart = "on-failure";
            RestartSec = "1m";
            Type = "oneshot";
            Environment = mapAttrsToList (name: value: "${name}=${value}") cfg.env;
            ExecStart = ''
              ${pkgs.kopia}/bin/kopia snap create ${concatStringsSep " " (map escapeShellArg value.snapshots)}
            '';
          };
        })
      cfg.jobs;

    systemd.user.timers =
      mapAttrs'
      (name: value:
        nameValuePair "kopia-${name}" {
          Unit = {Description = "Kopia periodic snapshotting - ${name}";};
          Timer =
            {
              Unit = "kopia-${name}.service";
              Persistent = true;
            }
            // value.timer;
          Install = {WantedBy = ["timers.target"];};
        })
      cfg.jobs;
  };
}
