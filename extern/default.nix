{ inputs }: with inputs;
{
  modules = [
    home.nixosModules.home-manager
    ci-agent.nixosModules.agent-profile
    sops-nix.nixosModules.sops
  ];

  overlays = [
    nur.overlay
    devshell.overlay
    (final: prev: {
      deploy-rs = deploy.packages.${prev.system}.deploy-rs;
    })
    sops-nix.overlay
    pkgs.overlay
    emacs-overlay.overlay
  ];

  # passed to all nixos modules
  specialArgs = {
    inherit inputs;
    overrideModulesPath = "${override}/nixos/modules";
    hardware = nixos-hardware.nixosModules;
  };

  # added to home-manager
  userModules = [
    nix-doom-emacs.hmModule
  ];

  # passed to all home-manager modules
  userSpecialArgs = {
    inherit inputs;
    modulesPath = "${inputs.home.outPath}/modules";
  };
}
