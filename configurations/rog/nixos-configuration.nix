{ inputs, self, ... }:
inputs.nixpkgs-25-11.lib.nixosSystem {
  specialArgs = {
    inherit inputs self;
  };
  modules = with self.modules.nixos; [
    inputs.sops-nix.nixosModules.sops
    role-devhost
    {
      system.stateVersion = "25.11";
      networking.hostId = "c1cb4f76";
      services.userborn.enable = true;
      users.mutableUsers = false;
      sops.defaultSopsFile = ../../secrets/rog.yaml;
      roles.devhost.enable = true;
    }
    ./hardware-config.nix
    ./networking.nix
    ./nixpkgs.nix
    ./users-knopki.nix
    ./users-root.nix
    ./inbox.nix
  ];
}
