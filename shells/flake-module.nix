# flake.parts' flakeModule
#
# Compliments devshell's flakeModule by auto load
# all dev shells from the "shells" directory.
#
{ ... }:
{
  lib,
  inputs,
  self,
  ...
}:
let
  inherit (builtins) filter map pathExists;
  inherit (lib.attrsets) mergeAttrsList;
  inherit (self.lib.filesystem) toImportedModuleAttr toImportedModuleAttr';
in
{
  imports = [ inputs.devshell.flakeModule ];

  config = {
    perSystem =
      {
        config,
        system,
        self',
        ...
      }:
      let
        shellModuleArgs = {
          inherit config inputs;
          inherit (self') packages;
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              allowUnsupportedSystem = true;
              cudaSupport = true;
            };
            overlays = [ self.overlays.default ];
          };
        };
        loadShells = loader: paths: mergeAttrsList (map (loader shellModuleArgs) (filter pathExists paths));
      in
      {
        # load devshells into prefixed `devshells-` attrs
        devshells = loadShells toImportedModuleAttr' [
          ./nix/shells/devshells
          ./shells/devshells
          ./devshells
        ];

        # load normal shells into root without prefix
        devShells = loadShells toImportedModuleAttr [
          ./nix/shells/devShells
          ./shells/devShells
          ./devShells
          ./shells
        ];
      };
  };
}
