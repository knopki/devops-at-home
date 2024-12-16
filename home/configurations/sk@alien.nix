{
  inputs,
  mkHomeConfiguration,
  self,
  ...
}:
let
  homeInput = inputs.home-23-11;
in
mkHomeConfiguration rec {
  inherit (homeInput.lib) homeManagerConfiguration;
  system = "x86_64-linux";
  pkgs = import homeInput.inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  modules = with self.modules.homeManager; [
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
      home.username = "sk";
      home.homeDirectory = "/home/sk";
    }
    profiles-sk-at-alien
  ];
}
