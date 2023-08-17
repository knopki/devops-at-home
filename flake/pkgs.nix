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
  flake-parts-lib,
  ...
}: let
  inherit (flake-parts-lib) perSystem;
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
            inherit (config.packages) version;
          })
        ];
      };
    in {
      _module.args.pkgs = nixpkgs;
      packages = import ../pkgs/all-packages.nix {
        inherit lib nixpkgsUnstable;
        pkgs = nixpkgs;
      };
    };
  };
}
