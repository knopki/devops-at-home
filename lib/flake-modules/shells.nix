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
  numtideDevshellsNamePath = import ../../shells/numtide-devshells.nix;
  shellsNamePath = import ../../shells/shells.nix;
in
{
  imports = [ inputs.devshell.flakeModule ];

  config = {
    perSystem =
      { config, system, ... }:
      let
        shellModuleArgs = {
          inherit config inputs;
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              allowUnsupportedSystem = true;
              cudaSupport = true;
            };
            overlays = [ self.overlays.my-packages ];
          };
        };
        loadShell = _: path: import path shellModuleArgs;
      in
      {
        devShells = mapAttrs loadShell shellsNamePath;

        # load numtide/devshells (not devShells)
        devshells = mapAttrs loadShell numtideDevshellsNamePath;
      };
  };
}
