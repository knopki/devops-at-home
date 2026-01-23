# flake.parts' flakeModule
#
# Load overlays from /overlays
#
{
  config,
  inputs,
  lib,
  self,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib.attrsets) mapAttrs;

  unstableOverlay = final: _prev: {
    nixpkgsUnstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config = self.lib.nixpkgsPolicies.configStandard;
    };
  };

  namePaths = import ../../overlays/overlays.nix;
  loadOverlay = _: import;

  myPackagesOverlay =
    _final: prev:
    let
      inherit (prev.stdenv.hostPlatform) system;
      inherit (config.allSystems.${system}) packages;
    in
    if (elem system config.systems) then packages else { };
in
{
  config.flake = {
    overlays = (mapAttrs loadOverlay namePaths) // {
      nixpkgs-unstable = unstableOverlay;
      # all packages of this flake
      my-packages = myPackagesOverlay;
      default = myPackagesOverlay;
    };
  };
}
