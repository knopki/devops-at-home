{
  inputs,
  mkNixosConfiguration,
  self,
  ...
}:
mkNixosConfiguration {
  inherit (inputs.nixpkgs-23-05.lib) nixosSystem;
  system = "x86_64-linux";
  modules = with self.modules.nixos; [
    inputs.home-23-05.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    home-manager
    ./meta.nix
    ./brave.nix
    ./core.nix
    ./nixpkgs.nix
    ./hardware-config.nix
    ./flatpak.nix
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
    {
      system.stateVersion = "20.09";
      networking.hostId = "ff0b9d65";
      networking.hostName = "alien";
      sops = {
        defaultSopsFile = ../../../secrets/alien.yaml;
      };

      # TODO: temporary
      documentation = {
        doc.enable = false;
        info.enable = false;
        man.enable = true;
        nixos.enable = false;
      };
    }
  ];
}
