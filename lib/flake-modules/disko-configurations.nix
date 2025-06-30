# flake.parts' flakeModule
#
# Load diskoConfiguration from /configurations
#
{ lib, self, ... }:
let
  inherit (lib.attrsets) mapAttrs;
  namePaths = import "${self.outPath}/configurations/disko-configurations.nix";
  loadConfiguration = _: path: import path;
in

{
  config.flake = {
    diskoConfigurations = mapAttrs loadConfiguration namePaths;
  };
}
