#
# flake.parts' flakeModule
#
# Load homeManagerModules and homeManagerConfigurations from ../home
#
{
  lib,
  self,
  ...
}: let
  inherit (lib.attrsets) mapAttrs;
  inherit (self.lib.filesystem) toModuleAttr;
in {
  config = {
    flake.homeManagerModules = toModuleAttr {src = ../home/modules;};

    flake.homeManagerConfigurations =
      mapAttrs (_: x: import x {inherit self;})
      (toModuleAttr {src = ../home/configurations;});
  };
}
