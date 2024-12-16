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
  inherit (builtins) attrValues elem filter;
  inherit (lib) getName;
  inherit (lib.attrsets) filterAttrs;
  inherit (flake-parts-lib) perSystem;
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
      # unstable nixpkgs - don't use for evaluation speed
      nixpkgsUnstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfreePredicate = pkg: elem (getName pkg) [ "anytype" "edl" ];
      };

      # primary nixpkgs
      # pkgs = import inputs.nixpkgs {
      #   inherit system;
      #   # overlays = [ self.overlays.default ];
      # };

      # additional input - nvfetcher sources
      sources = pkgs.callPackage ../pkgs/_sources/generated.nix { };

      pkgsByName = import ./. {
        inherit
          inputs
          pkgs
          nixpkgsUnstable
          sources
          ;
      };
      packages = filterAttrs (_: v: elem system v.meta.platforms) pkgsByName;
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
