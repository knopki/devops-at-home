{
  inputs,
  mkHomeConfiguration,
  self,
  ...
}:
let
  homeInput = inputs.home-24-11;
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
      home.username = "root";
      home.homeDirectory = "/root";
    }
    profiles-root-at-alien
  ];
}
