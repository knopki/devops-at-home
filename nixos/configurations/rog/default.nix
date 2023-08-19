{self, ...} @ specialArgs:
self.inputs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = with self.nixosModules; [
    profiles-workstation
    home-manager
    ./_hardware.nix
    ./_users-root.nix
    ./_users-knopki.nix
    {
      system.stateVersion = "23.05";
    }
  ];
}
