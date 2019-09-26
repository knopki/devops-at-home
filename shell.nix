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
          morph = super.callPackage "${fetchFromGitHub versions.morph}/nix-packaging" {};
          nixpkgs-fmt = super.unstable.nixpkgs-fmt;
          pulumi-bin = super.unstable.pulumi-bin.overrideAttrs (old: rec {
            version = "1.1.0";
            src = super.fetchurl {
              url = "https://get.pulumi.com/releases/sdk/pulumi-v${version}-linux-x64.tar.gz";
              sha256 = "1r498pxsjdj9mhdzh9vh4nw8fcjxfga44xlg43b0yakkgrp7c224";
            };
          });
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
    pulumi-bin
    shellcheck
    shfmt
    yarn
  ];
}
