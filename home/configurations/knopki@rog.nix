{self, ...}:
self.inputs.home.lib.homeManagerConfiguration rec {
  pkgs = self.inputs.nixpkgs.legacyPackages."x86_64-linux";
  modules = with self.homeModules; [
    {
      home.username = "knopki";
      home.homeDirectory = "/home/knopki";
    }
    self.homeModules.profiles-knopki-rog
  ];
}
