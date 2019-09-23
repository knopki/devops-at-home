let
  fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;
  versions = builtins.fromJSON
    (builtins.readFile ./nix/pkgs/versions.json);
  pkgs = import "${fetchFromGitHub versions.nixpkgs-stable}" {
    overlays = [
      (
        self: super: {
          unstable = import (fetchFromGitHub versions.nixpkgs-unstable) {
            config.allowUnfree = true;
          };
        }
      )
      (
        self: super: {
          morph = pkgs.callPackage "${fetchFromGitHub versions.morph}/nix-packaging" {};
          nixpkgs-fmt = super.unstable.nixpkgs-fmt;
          pulumi = pkgs.callPackage ./nix/pkgs/pulumi.nix {};
          shfmt = super.unstable.shfmt;
        }
      )
    ];
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    bashInteractive
    morph
    nix-prefetch-git
    nixpkgs-fmt
    nodejs
    openssh
    pulumi
    shellcheck
    shfmt
    yarn
  ];
}
