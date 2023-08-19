#
# flake.parts' flakeModule
#
# Load nixosModules and nixosConfigurations from ../nixos
#
{
  config,
  inputs,
  lib,
  flake-parts-lib,
  self,
  ...
}: let
  inherit (lib.attrsets) mapAttrs;
  inherit (self.lib.filesystem) toModuleAttr toModuleList;
in {
  config.flake = {
    nixosModules = toModuleAttr {src = ../nixos/modules;};

    nixosConfigurations =
      mapAttrs (_: x: import x config._module.specialArgs)
      (toModuleAttr {src = ../nixos/configurations;});
  };
}
