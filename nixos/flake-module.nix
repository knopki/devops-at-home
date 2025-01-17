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
  inherit (self.lib.filesystem) toModuleAttr toImportedModuleAttr;
  mkNixosConfiguration = self.lib.configuration.nixosConfigurationLoader {
    inherit inputs self withSystem;
  };
  toNixosConfigurations = toImportedModuleAttr { inherit inputs self mkNixosConfiguration; };
in
{
  config.flake = rec {
    nixosModules = toModuleAttr ./modules;
    modules.nixos = nixosModules;
    nixosConfigurations = toNixosConfigurations ./configurations;
  };
}
