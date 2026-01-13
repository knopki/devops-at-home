# flake.parts' flakeModule
#
# Load packages and overlays from /pkgs
#
{
  lib,
  self,
  ...
}:
let
  inherit (builtins)
    attrValues
    elem
    hasAttr
    ;
  inherit (lib.attrsets) filterAttrs;
in
{
  config.perSystem =
    { pkgs, system, ... }:
    let
      extLib = pkgs.lib.extend (_final: _prev: { extended = self.lib; });
      extPkgs = pkgs.extend (_final: _prev: { inherit self extLib; });
      pkgsByName = pkgs.lib.filesystem.packagesFromDirectoryRecursive {
        callPackage = extPkgs.callPackage;
        directory = ../../pkgs;
      };
      packages = filterAttrs (
        _: v: !(hasAttr "meta" v) || !(hasAttr "platforms" v.meta) || (elem system v.meta.platforms)
      ) pkgsByName;
      nonBrokenPackages = filterAttrs (_: pkg: pkg ? meta.broken -> !pkg.meta.broken) packages;
    in
    {
      packages = nonBrokenPackages;
      legacyPackages = packages;

      # add check: build all packages
      checks.buildPackages = pkgs.stdenv.mkDerivation {
        name = "all-packages";
        buildInputs = attrValues nonBrokenPackages;
        dontUnpack = true;
        installPhase = "mkdir -p $out";
      };
    };
}
