#
# flake.parts' flakeModule
#
# Compliments devshell's flakeModule by auto load
# all dev shells from the "shells" directory.
#
{
  flake-parts-lib,
  lib,
  inputs,
  self,
  ...
}: let
  inherit (lib.attrsets) mapAttrs;
  inherit (self.lib.filesystem) toModuleAttr toModuleAttr';
  inherit (flake-parts-lib) perSystem;
in {
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.devshell.flakeModule
  ];

  config = {
    perSystem = {
      config,
      lib,
      self',
      system,
      pkgs,
      ...
    }: let
      importShellAttrs = mapAttrs (_: x: import x {inherit config pkgs;});
      loadShells = src: importShellAttrs (toModuleAttr {inherit src;});
      loadShells' = src: importShellAttrs (toModuleAttr' {inherit src;});
    in {
      treefmt = {
        projectRootFile = "flake.nix";
        programs.alejandra.enable = true;
        settings.formatter.alejandra.excludes = [
          "old-digga/pkgs/_sources/generated.nix"
        ];
      };

      # load devshells into prefixed `devshells-` attrs
      devshells = loadShells' ../shells/devshells;
      # load normal shells into root without prefix
      devShells =
        (loadShells ../shells/devShells)
        // {
          # select default shell
          default = self'.devShells.devshells-nixos;
        };
    };
  };
}
