{
  inputs,
  mkNixosConfiguration,
  self,
  ...
}:
mkNixosConfiguration {
  inherit (inputs.nixpkgs-23-11.lib) nixosSystem;
  system = "x86_64-linux";
  modules = with self.modules.nixos; [
    inputs.home-23-11.nixosModules.default
    profiles-workstation
    ./_hardware.nix
    ./_nix.nix
    ./_nixpkgs.nix
    ./_networking.nix
    ./_sops.nix
    ./_users-root.nix
    ./_users-knopki.nix
    ./_graphical.nix
    {
      system.stateVersion = "23.11";
      networking.hostId = "c1cb4f76";
    }
  ];
}
