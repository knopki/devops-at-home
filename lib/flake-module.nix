# flake.parts' flakeModule
#
# Load library from ../lib
#
{
  inputs,
  flake-parts-lib,
  self',
  ...
}:
let
  inherit (flake-parts-lib) perSystem;
  myLib = import ./. {
    inherit (inputs.nixpkgs) lib;
    inherit (inputs) haumea;
  };
in
{
  config = {
    flake = {
      lib = myLib;
      schemas = inputs.flake-schemas.schemas // inputs.haumea.lib.load { src = ./schemas; };
    };
  };
}
