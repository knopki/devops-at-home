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
      inherit (final) system;
      config = self.lib.nixpkgsPolicies.configStandard;
    };
  };

  namePaths = import ../../overlays/overlays.nix;
  loadOverlay = _: path: import path;

  myPackagesOverlay =
    _final: prev:
    let
      system = prev.stdenv.hostPlatform.system;
      packages = config.allSystems.${system}.packages;
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
