{self, ...} @ specialArgs:
self.inputs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = with self.nixosModules; [
    profiles-workstation
    home-manager
  ];
}
