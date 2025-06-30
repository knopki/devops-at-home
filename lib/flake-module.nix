# flake.parts' flakeModule
#
# Load library from ../lib
#
{ inputs, ... }:
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
    };
  };
}
