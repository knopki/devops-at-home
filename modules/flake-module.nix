# flake.parts' flakeModule
#
# Load nixosModules, homeModules, shared, generic and other modules.
#

{
  lib,
  inputs,
  self,
  withSystem,
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
    homeModules = import ./home/module-attrset.nix;
    nixosModules = import ./nixos/module-attrset.nix;
    modules = {
      homeManager = homeModules;
      nixos = nixosModules;
    };
  };
}
