{ inputs, self, ... }:
inputs.nixpkgs-24-11.lib.nixosSystem {
  specialArgs = {
    inherit inputs self;
  };
  modules = with self.modules.nixos; [
    inputs.home-24-11.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    home-manager
    ./meta.nix
    ./brave.nix
    ./core.nix
    ./nixpkgs.nix
    ./hardware-config.nix
    ./profiles-flatpak.nix
    ./profiles-fonts.nix
    ./profiles-earlyoom.nix
    ./profiles-cryptowallets.nix
    ./profiles-passwords.nix
    ./profiles-web.nix
    ./profiles-desktop-essentials.nix
    ./profiles-desktop-kde.nix
    ./profiles-laptop.nix
    ./profiles-ws-virt.nix
    ./users-root.nix
    ./users-sk.nix
    ./containers.nix
    ./zfs.nix
    {
      system.stateVersion = "20.09";
      networking.hostId = "ff0b9d65";
      networking.hostName = "alien";
      sops = {
        defaultSopsFile = ../../secrets/alien.yaml;
      };

      # TODO: temporary
      documentation = {
        doc.enable = false;
        info.enable = false;
        man.enable = true;
        man.generateCaches = false;
        nixos.enable = false;
      };
    }
  ];
}
