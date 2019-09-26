let
  fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;
  versions = {
    nixpkgs-stable = {
      # NixOS 19.09 @ 2019-09-26
      owner = "NixOS";
      repo = "nixpkgs-channels";
      rev = "e34ac949d1b9847bfe09d90fdcaf2f92859a11dd";
      sha256 = "1yf9kw57d64g4153gd58bxnakhlyi9blk06gw169h37z186nsyxh";
    };
    devops-at-home = {
      # knopki/devops-at-home @ 2019-09-26
      owner = "knopki";
      repo = "devops-at-home";
      rev = "29f82083ab9ddebc76f1f64c0fcd5dbe62b50649";
      sha256 = "0pdl2g0hws5d99gamw64dbxag56z9skjjjkb7c7lcdva0w2ilmbz";
    };
  };
  pkgs = import "${fetchFromGitHub versions.nixpkgs-stable}" {
    overlays = [
      (
        self: super: {
          kube-score = super.callPackage "${fetchFromGitHub versions.devops-at-home}/nix/pkgs/kube-score" {};
          pulumi-bin = super.pulumi-bin.overrideAttrs (
            old: rec {
              version = "1.1.0";
              src = super.fetchurl {
                url = "https://get.pulumi.com/releases/sdk/pulumi-v${version}-linux-x64.tar.gz";
                sha256 = "1r498pxsjdj9mhdzh9vh4nw8fcjxfga44xlg43b0yakkgrp7c224";
              };
            }
          );
        }
      )
    ];
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    bashInteractive
    curl
    direnv
    google-cloud-sdk
    jq
    kube-score
    kubectl
    nodejs
    openssh
    patch
    php
    php73Packages.composer
    pulumi-bin
    python37Packages.pip
    python37Packages.virtualenv
    python3Full
    rsync
    yarn
  ];
}
