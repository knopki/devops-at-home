{
  lib,
  config,
  self,
  ...
}:
{
  # Disable nix channels. Use flakes instead.
  nix.channel.enable = lib.mkDefault false;

  # Fallback quickly if substituters are not available.
  nix.settings.connect-timeout = lib.mkDefault 5;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ]
  ++ (self.nixConfig.experimental-features or [ ])
  ++ lib.optional (lib.versionOlder (lib.versions.majorMinor config.nix.package.version) "2.22") "repl-flake";

  # The default at 10 is rarely enough.
  nix.settings.log-lines = lib.mkDefault 25;

  # Avoid disk full issues
  nix.settings.max-free = lib.mkDefault (3000 * 1024 * 1024);
  nix.settings.min-free = lib.mkDefault (512 * 1024 * 1024);
  nix.settings.tarball-ttl = lib.mkDefault (86400 * 30);
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-then 30d";
  };

  # Avoid copying unnecessary stuff over SSH
  nix.settings.builders-use-substitutes = true;

  # De-duplicate store paths using hardlinks except in containers
  # where the store is host-managed.
  nix.optimise.automatic = lib.mkDefault (!config.boot.isContainer);

  # If the user is in @wheel they are trusted by default.
  nix.settings.trusted-users = [ "@wheel" ];

  nix.daemonCPUSchedPolicy = lib.mkDefault "batch";
  nix.daemonIOSchedClass = lib.mkDefault "idle";
  nix.daemonIOSchedPriority = lib.mkDefault 7;

  systemd.services.nix-gc.serviceConfig = {
    CPUSchedulingPolicy = lib.mkDefault "batch";
    IOSchedulingClass = lib.mkDefault "idle";
    IOSchedulingPriority = lib.mkDefault 7;
  };

  # Make builds to be more likely killed than important services.
  # 100 is the default for user slices and 500 is systemd-coredumpd@
  # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;
}
