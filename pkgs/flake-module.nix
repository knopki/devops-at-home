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
  inherit (lib) getName getNameWithVersion;
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

  allowlistedLicenses = with lib.licenses; [ ];
  allowUnfreePredicate =
    pkg:
    elem (getName pkg) [
      "anytype"
      "deezer-desktop"
      "edl"
      "pantum-driver"
    ];
  allowInsecurePredicate = pkg: elem (getNameWithVersion pkg) [ ];
  commonNixpkgsConfig = {
    inherit
      allowlistedLicenses
      allowUnfreePredicate
      allowInsecurePredicate
      ;
  };
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
        overlays = [ self.overlays.default ];
        config = commonNixpkgsConfig;
      };

      # unstable nixpkgs - don't use for evaluation speed
      nixpkgsUnstable = import inputs.nixpkgs-unstable {
        inherit system;
        overlays = [ self.overlays.default ];
        config = commonNixpkgsConfig;
      };

      pkgsByName = import ./. {
        inherit
          self
          inputs
          nixpkgs-24-11
          nixpkgsUnstable
          ;
        pkgs = nixpkgs-24-11;
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
    default = _: __: { }; # mkOverlay [ "aliza" ];
    update = mkOverlay [ ];
  };

}
