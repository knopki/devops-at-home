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
    filter
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
      nonBrokenPackages = filter (pkg: pkg ? meta.broken -> !pkg.meta.broken) (attrValues packages);
    in
    {
      inherit packages;
      legacyPackages = packages;

      # add check: build all packages
      checks.buildPackages = pkgs.stdenv.mkDerivation {
        name = "all-packages";
        buildInputs = nonBrokenPackages;
        dontUnpack = true;
        installPhase = "mkdir -p $out";
      };
    };
}
