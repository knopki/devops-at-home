# flake.parts' flakeModule
#
# Load nixosConfigurations from /configurations
#
{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (lib.attrsets) mapAttrs;
  namePaths = import "${self.outPath}/configurations/nixos-configurations.nix";
  loadConfiguration = path: import path { inherit inputs self; };
in
{
  config.flake = {
    nixosConfigurations = mapAttrs (_: loadConfiguration) namePaths;
  };
}
