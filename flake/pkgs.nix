#
# flake.parts' flakeModule
#
# Load packages and overlays from ../pkgs
#
# See also:
# How to implement per host nixpkgs version:
# https://github.com/hercules-ci/flake-parts/issues/96#issuecomment-1420196400
{
  inputs,
  lib,
  flake-parts-lib,
  self,
  ...
}: let
  inherit (lib.attrsets) mapAttrs;
  inherit (flake-parts-lib) perSystem;
  inherit (self.lib.filesystem) toModuleAttr;
in {
  config = {
    perSystem = {
      config,
      lib,
      pkgs,
      system,
      ...
    }: let
      # unstable unfree nixpkgs - don't use for evaluation speed
      nixpkgsUnstable = import inputs.nixpkgsUnstable {
        inherit system;
        config.allowUnfree = true;
      };

      # primary unfree nixpkgs
      nixpkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          # is that really necessary? no, just use packages from config.packages
          (_: final: {
            # inherit (config.packages) version;
          })
        ];
      };

      # additional input - nvfetcher sources
      sources = pkgs.callPackage ../pkgs/_sources/generated.nix {};

      # package loader with additional inputs
      pkgsInputs = pkgs // { inherit nixpkgsUnstable sources; };
      callPackage = lib.callPackageWith pkgsInputs;

      # load packages
      importPackagesAttrs = mapAttrs (_: x: callPackage x { });
      packages = importPackagesAttrs (toModuleAttr { src = ../pkgs; });
    in {
      inherit packages;
      _module.args.pkgs = nixpkgs;
    };
  };
}
