{
  config,
  self,
  self',
  inputs,
  inputs',
  extLib,
  lib,
  ...
}:
{
  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;

    # additional args to all homeModules
    # default: { lib, pkgs, modulesPath, osConfig }
    extraSpecialArgs = self.lib.configuration.mkSpecialArgs {
      inherit
        config
        inputs
        inputs'
        self
        self'
        extLib
        ;
    };

    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
