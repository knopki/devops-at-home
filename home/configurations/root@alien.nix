{
  inputs,
  mkHomeConfiguration,
  self,
  ...
}:
let
  homeInput = inputs.home-23-05;
in
mkHomeConfiguration rec {
  inherit (homeInput.lib) homeManagerConfiguration;
  system = "x86_64-linux";
  pkgs = import homeInput.inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  modules = with self.modules.home; [
    {
      home.username = "root";
      home.homeDirectory = "/root";
    }
    profiles-root-at-alien
  ];
}
