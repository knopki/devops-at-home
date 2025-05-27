{
  inputs,
  mkNixosConfiguration,
  self,
  ...
}:
mkNixosConfiguration {
  inherit (inputs.nixpkgs-25-05.lib) nixosSystem;
  system = "x86_64-linux";
  modules = with self.modules.nixos; [
    inputs.sops-nix.nixosModules.sops
    inputs.preservation.nixosModules.preservation
    profiles-workstation
    {
      system.stateVersion = "25.05";
      networking.hostId = "c1cb4f76";
      services.userborn.enable = true;
      users.mutableUsers = false;
      sops.defaultSopsFile = ../../../secrets/rog.yaml;
    }
    ./graphical.nix
    ./hardware.nix
    ./networking.nix
    ./nix.nix
    ./nixpkgs.nix
    ./users-knopki.nix
    ./users-root.nix
    ./inbox.nix
  ];
}
