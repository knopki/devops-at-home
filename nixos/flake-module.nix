# flake.parts' flakeModule
#
# Load nixosModules and nixosConfigurations from ./nixos
#
{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
let
  inherit (lib.attrsets) mapAttrs;
  mkNixosConfiguration = self.lib.configuration.nixosConfigurationLoader {
    inherit inputs self withSystem;
  };
  namePathAttrset = import ./nixos-configurations.nix;
in
{
  config.flake = {
    nixosConfigurations = mapAttrs (
      _: path: import path { inherit inputs self mkNixosConfiguration; }
    ) namePathAttrset;
  };
}
