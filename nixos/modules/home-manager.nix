{
  config,
  inputs,
  self,
  pkgs,
  ...
}: {
  imports = [
    self.inputs.home.nixosModules.default
  ];

  config = {
    environment.systemPackages = with pkgs; [hello];
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    # additional args to all homeManagerModules
    # default: { lib, modulesPath, nixosConfig, osConfig }
    home-manager.extraSpecialArgs = {
      # inherit self inputs;
    };
  };
}
