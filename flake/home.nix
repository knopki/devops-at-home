#
# flake.parts' flakeModule
#
# Load homeModules and homeConfigurations from ../home
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
    flake.homeModules = toModuleAttr {src = ../home/modules;};

    flake.homeConfigurations =
      mapAttrs (_: x: import x {inherit self;})
      (toModuleAttr {src = ../home/configurations;});
  };
}
