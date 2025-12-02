# flake.parts' flakeModule
#
# Compliments devshell's flakeModule by auto load
# all dev shells from the "shells" directory.
#
{
  lib,
  inputs,
  self,
  ...
}:
let
  inherit (lib.attrsets) mapAttrs;
  shellsNamePath = import ../../shells/shells.nix;
in
{
  config = {
    perSystem =
      { config, system, ... }:
      let
        shellModuleArgs = {
          inherit config inputs;
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = self.lib.nixpkgsPolicies.configStandard // {
              allowUnsupportedSystem = true;
            };
            overlays = with self.overlays; [
              my-packages
              nixpkgs-unstable
              unstable-backports
            ];
          };
        };
        loadShell = _: path: import path shellModuleArgs;
      in
      {
        devShells = mapAttrs loadShell shellsNamePath;
      };
  };
}
