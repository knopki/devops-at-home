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
  self,
  ...
}: let
  inherit (flake-parts-lib) perSystem;
in {
  config = {
    perSystem = {
      config,
      inputs',
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
      pkgsInputs = {inherit lib nixpkgsUnstable pkgs;};
    in {
      # This sets `pkgs` to a nixpkgs with allowUnfree option set and overlays
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          # is that really necessary?
          (_: final: import ../pkgs (pkgsInputs // {pkgs = final;}))
        ];
      };

      packages = import ../pkgs pkgsInputs;
    };
  };
}
