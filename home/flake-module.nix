# flake.parts' flakeModule
#
# Load homeModules and homeConfigurations from ./home
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
  inherit (self.lib.filesystem) toImportedModuleAttr;
  mkHomeConfiguration = self.lib.configuration.homeConfigurationLoader {
    inherit withSystem self inputs;
  };
  toHomeConfigurations = toImportedModuleAttr { inherit inputs mkHomeConfiguration self; };
in
{
  options.flake = {
    homeConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''
        Instantiated HomeManager configurations.

        `homeConfigurations` is for specific user on machines. If you want to expose
        reusable configurations, add them to [`homeModules`](#opt-flake.homeModules)
        in the form of modules (no `lib.homeManagerConfiguration`), so that you can
        reference them in this or another flake's `homeConfigurations`.
      '';
    };
  };
  config.flake = rec {
    homeConfigurations = toHomeConfigurations ./configurations;
  };
}
