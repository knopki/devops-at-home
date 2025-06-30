{
  self,
  inputs,
  extLib,
  ...
}:
{
  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;

    # additional args to all homeModules
    # default: { lib, pkgs, modulesPath, osConfig }
    extraSpecialArgs = {
      inherit inputs self extLib;
    };

    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
