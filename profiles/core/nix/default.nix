{ lib, ... }:
let inherit (lib) mkDefault mkBefore; in
{
  nix = {
    allowedUsers = mkDefault [ "@wheel" ];
    autoOptimiseStore = mkDefault true;
    daemonIONiceLevel = mkDefault 7;
    daemonNiceLevel = mkDefault 19;
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      options = mkDefault "--delete-older-then 30d";
    };
    optimise.automatic = mkDefault true;
    extraOptions =
      let
        gb = 1024 * 1024 * 1024;
      in
      mkBefore ''
        min-free = ${toString (gb * 10)}
        max-free = ${toString (gb * 20)}
        tarball-ttl = ${toString (86400 * 30)}
      '';
    trustedUsers = mkDefault [ "root" "@wheel" ];
  };

  systemd.services.nix-daemon.serviceConfig.LimitSTACKSoft = "infinity";

  systemd.timers = {
    nix-gc.timerConfig.Persistent = mkDefault true;
    nix-optimise.timerConfig.Persistent = mkDefault true;
  };
}
