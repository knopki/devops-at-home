{
  self,
  lib,
  config,
  ...
}:
let
  inherit (lib.lists) optional;
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.strings) versionOlder;
  inherit (lib.versions) majorMinor;
  cfg = config.profiles.nix;
in
{
  options.profiles.nix = {
    enable = mkEnableOption "Enable trusted nix caches";
    nh.enable = mkEnableOption "Enable nh and nh clean";
  };

  config = mkIf cfg.enable {
    # Disable nix channels. Use flakes instead.
    nix.channel.enable = mkDefault false;

    # Fallback quickly if substituters are not available.
    nix.settings.connect-timeout = mkDefault 5;

    # Enable flakes
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ]
    ++ (self.nixConfig.experimental-features or [ ])
    ++ optional (versionOlder (majorMinor config.nix.package.version) "2.22") "repl-flake";

    # The default at 10 is rarely enough.
    nix.settings.log-lines = mkDefault 25;

    # Avoid disk full issues
    nix.settings.max-free = mkDefault (3000 * 1024 * 1024);
    nix.settings.min-free = mkDefault (512 * 1024 * 1024);
    nix.settings.tarball-ttl = mkDefault (86400 * 30);
    nix.gc = {
      automatic = mkDefault (!config.programs.nh.clean.enable);
      dates = mkDefault "daily";
      options = mkDefault "--delete-older-then 7d";
    };

    # Avoid copying unnecessary stuff over SSH
    nix.settings.builders-use-substitutes = true;

    # De-duplicate store paths using hardlinks except in containers
    # where the store is host-managed.
    nix.optimise.automatic = mkDefault (!config.boot.isContainer);

    # If the user is in @wheel they are trusted by default.
    nix.settings.trusted-users = [ "@wheel" ];

    nix.daemonCPUSchedPolicy = mkDefault "batch";
    nix.daemonIOSchedClass = mkDefault "idle";
    nix.daemonIOSchedPriority = mkDefault 7;

    systemd.services.nix-gc.serviceConfig = {
      CPUSchedulingPolicy = mkDefault "batch";
      IOSchedulingClass = mkDefault "idle";
      IOSchedulingPriority = mkDefault 7;
    };

    # Make builds to be more likely killed than important services.
    # 100 is the default for user slices and 500 is systemd-coredumpd@
    # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
    systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = mkDefault 250;

    # Caches in trusted-substituters can be used by unprivileged users i.e. in
    # flakes but are not enabled by default.
    nix.settings.trusted-substituters = [
      "https://cache.garnix.io"
      "https://nix-community.cachix.org"
    ]
    ++ (self.nixConfig.extra-substituters or [ ]);
    nix.settings.trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ]
    ++ (self.nixConfig.extra-trusted-public-keys or [ ]);

    # nh settions
    programs.nh = mkIf cfg.nh.enable {
      enable = lib.mkDefault true;
      flake = lib.mkDefault self.outPath;
      clean = {
        enable = lib.mkDefault true;
        dates = lib.mkDefault "daily";
        extraArgs = "--keep 5 --keep-since 1weeks";
      };
    };
  };
}
