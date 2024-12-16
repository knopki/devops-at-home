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
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.devshell.flakeModule
  ];

  config = {
    perSystem =
      {
        config,
        lib,
        pkgs,
        system,
        ...
      }:
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
          };
        };
        loadShells = loader: paths: mergeAttrsList (map (loader shellModuleArgs) (filter pathExists paths));
      in
      {
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            deadnix = {
              enable = true;
              no-lambda-pattern-names = true;
            };
            jsonfmt.enable = true;
            mdformat.enable = true;
            nixfmt.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;
            yamlfmt.enable = true;
          };
          settings = {
            global.excludes = [
              "old-digga/**"
              "pkgs/_sources/**"
              "*@*.yaml"
              "secrets.yaml"
              "secrets/*@*.yaml"
              "*.asc"
              ".envrc"
              ".gitkeep"
              ".sops.yaml"
              "LICENSE"
            ];
          };
        };

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
