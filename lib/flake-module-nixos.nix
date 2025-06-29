# flake.parts' flakeModule
#
# Load nixosModules and nixosConfigurations from ./nixos
#
{
  inputs,
  self,
  withSystem,
  ...
}:
{
  config.flake = {
    nixosConfigurations = self.lib.configuration.mkNixosConfigurationsAttrset {
      inherit inputs self withSystem;
      configurations = import ../configurations/nixos-configurations.nix;
    };
  };
}
