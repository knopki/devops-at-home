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
  cfg = config.custom.nix;
in
{
  options.custom.nix = {
    enable = mkEnableOption "Enable trusted nix caches";
    nh.enable = mkEnableOption "Enable nh and nh clean";
  };

  config = mkIf cfg.enable {
    nix = {
      # Disable nix channels. Use flakes instead.
      channel.enable = mkDefault false;

      settings = {
        # Fallback quickly if substituters are not available.
        connect-timeout = mkDefault 5;

        # The default at 10 is rarely enough.
        log-lines = mkDefault 25;

        # Enable flakes
        experimental-features = [
          "nix-command"
          "flakes"
        ]
        ++ optional (versionOlder (majorMinor config.nix.package.version) "2.22") "repl-flake";

        # Avoid disk full issues
        max-free = mkDefault (3000 * 1024 * 1024);
        min-free = mkDefault (512 * 1024 * 1024);
        tarball-ttl = mkDefault (86400 * 30);

        # Avoid copying unnecessary stuff over SSH
        builders-use-substitutes = true;

        # If the user is in @wheel they are trusted by default.
        trusted-users = [ "@wheel" ];

        substituters = [
          "https://mirror.yandex.ru/nixos"
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://cache.numtide.com"
          "https://cache.garnix.io"
          "https://lanzaboote.cachix.org"
          "https://devenv.cachix.org"
        ];

        # Caches in trusted-substituters can be used by unprivileged users i.e. in
        # flakes but are not enabled by default.
        trusted-substituters = [
          "https://mirror.yandex.ru/nixos"
          "https://cache.nixos.org"
        ];

        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      };

      # Avoid disk full issues
      gc = {
        automatic = mkDefault (!config.programs.nh.clean.enable);
        dates = mkDefault "daily";
        options = mkDefault "--delete-older-then 7d";
      };

      # De-duplicate store paths using hardlinks except in containers
      # where the store is host-managed.
      optimise.automatic = mkDefault (!config.boot.isContainer);

      daemonCPUSchedPolicy = mkDefault "batch";
      daemonIOSchedClass = mkDefault "idle";
      daemonIOSchedPriority = mkDefault 7;

    };

    systemd.services.nix-gc.serviceConfig = {
      CPUSchedulingPolicy = mkDefault "batch";
      IOSchedulingClass = mkDefault "idle";
      IOSchedulingPriority = mkDefault 7;
    };

    # Make builds to be more likely killed than important services.
    # 100 is the default for user slices and 500 is systemd-coredumpd@
    # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
    systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = mkDefault 250;

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
