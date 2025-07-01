# flake.parts' flakeModule
#
# Load nixosModules, homeModules, shared, generic and other modules.
#

{
  lib,
  self,
  moduleLocation ? "${self.outPath}/flake.nix",
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (lib.attrsets) mapAttrs;
in
{
  options = {
    homeModules = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
      apply = mapAttrs (
        k: v: {
          _file = "${toString moduleLocation}#homeModules.${k}";
          imports = [ v ];
        }
      );
      description = ''
        HomeManager modules.

        You may use this for reusable pieces of configuration, service modules, etc.
      '';
    };
  };

  config.flake = rec {
    homeModules = import ../../modules/home/home-modules.nix;
    nixosModules = import ../../modules/nixos/nixos-modules.nix;
    modules = {
      homeManager = homeModules;
      nixos = nixosModules;
      shared = import ../../modules/shared/shared-modules.nix;
    };
  };
}
