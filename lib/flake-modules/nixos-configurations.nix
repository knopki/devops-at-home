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
  loadConfiguration = _: path: import path { inherit inputs self; };
in
{
  config.flake = {
    nixosConfigurations = mapAttrs loadConfiguration namePaths;
  };
}
