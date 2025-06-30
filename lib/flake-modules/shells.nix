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
  devshellsNamePath = import "${self.outPath}/shells/devshells.nix";
  devShellsNamePath = import "${self.outPath}/shells/devShells.nix";
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
            overlays = [ self.overlays.myPackages ];
          };
        };
        loadShell = _: path: import path shellModuleArgs;
      in
      {
        devShells = mapAttrs loadShell devShellsNamePath;

        # load numtide/devshells (not devShells)
        devshells = mapAttrs loadShell devshellsNamePath;
      };
  };
}
