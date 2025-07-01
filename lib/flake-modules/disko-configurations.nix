# flake.parts' flakeModule
#
# Load diskoConfiguration from /configurations
#
{ lib, ... }:
let
  inherit (lib.attrsets) mapAttrs;
  namePaths = import ../../configurations/disko-configurations.nix;
  loadConfiguration = _: path: import path;
in

{
  config.flake = {
    diskoConfigurations = mapAttrs loadConfiguration namePaths;
  };
}
