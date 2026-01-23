# flake.parts' flakeModule
#
# Load diskoConfiguration from /configurations
#
{ lib, ... }:
let
  inherit (lib.attrsets) mapAttrs;
  namePaths = import ../../configurations/disko-configurations.nix;
  loadConfiguration = _: import;
in

{
  config.flake = {
    diskoConfigurations = mapAttrs loadConfiguration namePaths;
  };
}
