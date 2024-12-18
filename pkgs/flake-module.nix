# flake.parts' flakeModule
#
# Load packages and overlays from /pkgs
#
{
  inputs,
  lib,
  flake-parts-lib,
  self,
  ...
}:
let
  inherit (builtins)
    attrValues
    elem
    hasAttr
    filter
    ;
  inherit (lib) getName getNameWithVersion;
  inherit (lib.attrsets) filterAttrs;
  inherit (flake-parts-lib) perSystem;
  allowlistedLicenses = with lib.licenses; [ ];
  allowUnfreePredicate =
    pkg:
    elem (getName pkg) [
      "anytype"
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
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

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
        # overlays = [ self.overlays.default ];
        config = commonNixpkgsConfig;
      };

      # unstable nixpkgs - don't use for evaluation speed
      nixpkgsUnstable = import inputs.nixpkgs-unstable {
        inherit system;
        config = commonNixpkgsConfig;
      };

      # additional input - nvfetcher sources
      sources = pkgs.callPackage ../pkgs/_sources/generated.nix { };

      pkgsByName = import ./. {
        inherit
          self
          inputs
          pkgs
          nixpkgs-24-11
          nixpkgsUnstable
          sources
          ;
      };
      packages = filterAttrs (
        _: v: !(hasAttr "meta" v) || !(hasAttr "platforms" v.meta) || (elem system v.meta.platforms)
      ) pkgsByName;
    in
    {
      inherit packages;

      checks.buildPackages = pkgs.stdenv.mkDerivation {
        name = "all-packages";
        buildInputs = filter (pkg: pkg ? meta.broken -> !pkg.meta.broken) (attrValues packages);
        dontUnpack = true;
        installPhase = "mkdir -p $out";
      };
    };
}
