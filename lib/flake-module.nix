# flake.parts' flakeModule
#
# Load library from ../lib
#
{ inputs, self', ... }:
let
  myLib = import ./. {
    inherit (inputs.nixpkgs-lib) lib;
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
