with import <nixpkgs> { };
let
  versions = builtins.fromJSON
    (builtins.readFile ./roles/nixos/files/pkgs/versions.json);
  pkgs = import "${fetchFromGitHub versions.nixpkgs-stable}" {
    overlays = [
      (self: super: {
        unstable = import (fetchFromGitHub versions.nixpkgs-unstable) {
          config.allowUnfree = true;
        };
        nixfmt = import (fetchFromGitHub versions.nixfmt) { };
        pulumi = pkgs.callPackage ./roles/nixos/files/pkgs/pulumi.nix { };
      })
    ];
  };
in mkShell {
  buildInputs = with pkgs; [
    ansible
    nix-prefetch-git
    nixfmt
    nodejs
    pulumi
    yarn
  ];
}
