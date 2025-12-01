{ inputs, self, ... }:
inputs.nixpkgs-25-05.lib.nixosSystem {
  specialArgs = {
    inherit inputs self;
  };
  modules = with self.modules.nixos; [
    inputs.sops-nix.nixosModules.sops
    role-devhost
    ./inbox.nix
    ./nixpkgs.nix
    ./hardware-config.nix
    ./profiles-flatpak.nix
    ./profiles-fonts.nix
    ./profiles-earlyoom.nix
    ./profiles-cryptowallets.nix
    ./profiles-desktop-essentials.nix
    ./profiles-laptop.nix
    ./profiles-ws-virt.nix
    ./restic.nix
    ./users-root.nix
    ./users-sk.nix
    ./containers.nix
    ./zfs.nix
    {
      system.stateVersion = "20.09";
      networking.hostId = "ff0b9d65";
      networking.hostName = "alien";
      sops.defaultSopsFile = ../../secrets/alien.yaml;

      roles.devhost.enable = true;
    }
  ];
}
