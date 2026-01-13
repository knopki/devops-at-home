{
  self,
  inputs,
  extLib,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.home-manager;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  options.custom.home-manager.enable = mkEnableOption "Enable home-manager profile";

  config = mkIf cfg.enable {
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
  };
}
