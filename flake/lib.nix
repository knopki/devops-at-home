#
# flake.parts' flakeModule
#
# Load library from ../lib
#
{
  inputs,
  flake-parts-lib,
  ...
}: let
  inherit (inputs) haumea;
  inherit (flake-parts-lib) perSystem;
in {
  config = {
    flake.lib = haumea.lib.load {
      src = ../lib;
      inputs = {
        inherit (inputs.nixpkgs) lib;
        inherit haumea;
      };
    };

    perSystem = {
      lib,
      self',
      ...
    }: {
      _module.args.lib = lib.extend (_: _: {extended = self'.lib;});
    };
  };
}
