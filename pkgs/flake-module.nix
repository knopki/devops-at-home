# flake.parts' flakeModule
#
# Load packages and overlays from /pkgs
#
{
  inputs,
  config,
  lib,
  self,
  withSystem,
  perSystem,
  ...
}:
let
  inherit (builtins)
    attrValues
    elem
    hasAttr
    filter
    length
    listToAttrs
    ;
  inherit (lib.attrsets) filterAttrs nameValuePair;

  mkOverlay =
    pkgNames: _final: prev:
    let
      system = prev.stdenv.hostPlatform.system;
      packages = config.allSystems.${system}.packages;
      inheritPackages = listToAttrs (map (x: nameValuePair x packages.${x}) pkgNames);
      overlay = if (length pkgNames == 0) then packages else inheritPackages;
    in
    if (elem system config.systems) then overlay else { };

in
{
  config.perSystem =
    {
      config,
      lib,
      pkgs,
      system,
      ...
    }:
    let
      # primary nixpkgs
      nixpkgs-24-11 = import inputs.nixpkgs-24-11 {
        inherit system;
        overlays = [
          self.overlays.default
        ];
        config = import ./nixpkgs-config.nix { inherit lib; };
      };

      nixpkgs-25-05 = import inputs.nixpkgs-25-05 {
        inherit system;
        overlays = [
          self.overlays.default
        ];
        config = import ./nixpkgs-config.nix { inherit lib; };
      };

      # unstable nixpkgs - don't use for evaluation speed
      nixpkgsUnstable = import inputs.nixpkgs-unstable {
        inherit system;
        overlays = [ self.overlays.default ];
        config = import ./nixpkgs-config.nix { inherit lib; };
      };

      pkgsByName = import ./. {
        inherit
          nixpkgs-24-11
          nixpkgs-25-05
          nixpkgsUnstable
          self
          ;
        pkgs = nixpkgs-25-05;
      };
      packages = filterAttrs (
        _: v: !(hasAttr "meta" v) || !(hasAttr "platforms" v.meta) || (elem system v.meta.platforms)
      ) pkgsByName;
    in
    {
      inherit packages;
      legacyPackages = packages;

      checks.buildPackages = pkgs.stdenv.mkDerivation {
        name = "all-packages";
        buildInputs = filter (pkg: pkg ? meta.broken -> !pkg.meta.broken) (attrValues packages);
        dontUnpack = true;
        installPhase = "mkdir -p $out";
      };
    };

  config.flake.overlays = {
    default =
      _final: prev:
      let
        system = prev.stdenv.hostPlatform.system;
        pythonPackages = inputs.nixpkgs-python.packages.${system};
      in
      {
        python37 = pythonPackages."3.7";
      };
    myPackages = mkOverlay [ ];
    update = mkOverlay [ ];
  };

}
