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

  loadConf = x: import x config._module.specialArgs;
in {
  config = {
    flake.nixosModules = toModuleAttr {src = ../nixos/modules;};

    flake.nixosConfigurations =
      mapAttrs (_: loadConf)
      (toModuleAttr {src = ../nixos/configurations;});
  };
}
