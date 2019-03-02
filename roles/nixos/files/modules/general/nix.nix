{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.general.nix.enable = mkEnableOption "NIX Options";
  };

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
      };

      optimise = {
        automatic = true;
        dates = [ "4:15" ];
      };

      binaryCaches = [
        "https://cache.nixos.org/"
        "https://nixpkgs-wayland.cachix.org"
      ];

      binaryCachePublicKeys = [
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];

      trustedUsers = [ "root" "@wheel" ];
    };
  };
}
