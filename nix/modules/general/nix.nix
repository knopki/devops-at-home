{ config, pkgs, lib, ... }:

with lib;

{
  options = { local.general.nix.enable = mkEnableOption "NIX Options"; };

  config = {
    nix = mkIf config.local.general.nix.enable {
      # autoOptimiseStore = true;
      daemonIONiceLevel = 7;
      daemonNiceLevel = 10;
      distributedBuilds = true;
      useSandbox = true;

      extraOptions = ''
        gc-keep-outputs = true
        gc-keep-derivations = true
        tarball-ttl = ${toString (60 * 60 * 96)}
      '';

      gc = {
        automatic = true;
        dates = "3:15";
        options = "--delete-older-than 30d";
      };

      optimise = {
        automatic = true;
        dates = [ "4:15" ];
      };

      binaryCaches = [
        "https://cache.nixos.org/"
        "https://nixfmt.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
      ];

      binaryCachePublicKeys = [
        "nixfmt.cachix.org-1:uyEQg16IhCFeDpFV07aL+Dbmh18XHVUqpkk/35WAgJI="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];

      trustedUsers = [ "root" "@wheel" ];
    };

    systemd.timers = {
      nix-gc.timerConfig.Persistent = true;
      nix-optimise.timerConfig.Persistent = true;
      nixos-upgrade.timerConfig.Persistent = true;
    };
  };
}
