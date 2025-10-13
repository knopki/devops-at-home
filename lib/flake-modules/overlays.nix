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

  # backport for legacy systems
  nixpkgs2505Overlay = final: _prev: {
    nixpkgs-25-05 = import inputs.nixpkgs-25-05 {
      inherit (final) system;
      config = self.lib.nixpkgsPolicies.configStandard;
    };
  };

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
      nixpkgs-25-05 = nixpkgs2505Overlay;
      nixpkgs-unstable = unstableOverlay;
      # all packages of this flake
      my-packages = myPackagesOverlay;
      default = myPackagesOverlay;
    };
  };
}
