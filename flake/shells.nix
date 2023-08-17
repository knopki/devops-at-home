#
# flake.parts' flakeModule
#
# Compliments devshell's flakeModule by auto load
# all dev shells from the "shells" directory.
#
{
  flake-parts-lib,
  inputs,
  self,
  ...
}: let
  inherit (self.lib.filesystem) haumeaLoaders toModuleAttr toModuleAttr';
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
      args = {
        loader = haumeaLoaders.default;
        inputs = {inherit config pkgs;};
      };
    in {
      treefmt = {
        projectRootFile = "flake.nix";
        programs.alejandra.enable = true;
        settings.formatter.alejandra.excludes = [
          "old-digga/pkgs/_sources/generated.nix"
        ];
      };

      devshells = toModuleAttr' (args // {src = ../shells/devshells;});
      devShells =
        toModuleAttr (args // {src = ../shells/devShells;})
        // {
          default = self'.devShells.devshells-nix;
        };
    };
  };
}
