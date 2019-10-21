let
  fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;
  versions = {
    nixpkgs-stable = {
      # NixOS 19.09 @ 2019-10-21
      owner = "NixOS";
      repo = "nixpkgs-channels";
      rev = "8bf142e001b6876b021c8ee90c2c7cec385fe8e9";
      sha256 = "1z8id8ix24ds9i7cm8g33v54j7xbhcpwzw50wlq00alj00xrq307";
    };
    nixpkgs-unstable = {
      # NixOS unstable @ 2019-10-21
      owner = "NixOS";
      repo = "nixpkgs-channels";
      rev = "1c40ee6fc44f7eb474c69ea070a43247a1a2c83c";
      sha256 = "0xvgx4zsz8jk125xriq7jfp59px8aa0c5idbk25ydh2ly7zmb2df";
    };
    devops-at-home = {
      # knopki/devops-at-home @ 2019-09-26
      owner = "knopki";
      repo = "devops-at-home";
      rev = "29f82083ab9ddebc76f1f64c0fcd5dbe62b50649";
      sha256 = "0pdl2g0hws5d99gamw64dbxag56z9skjjjkb7c7lcdva0w2ilmbz";
    };
    nixpkgs-kustomize-1 = {
      owner = "NixOS";
      repo = "nixpkgs-channels";
      rev = "2d5908f89bab59c2c4f88fbfc900dfff9baa55f0";
      sha256 = "04igl9i8x7bglwyc0fkn8fy7vcnx0f5wf2h66s818y5ywg37l020";
    };
  };
  pkgs = import "${fetchFromGitHub versions.nixpkgs-stable}" {
    overlays = [
      (
        self: super: {
          unstable = import (fetchFromGitHub versions.nixpkgs-unstable) {};
        }
      )
      (
        self: super: {
          kube-score = super.callPackage "${fetchFromGitHub versions.devops-at-home}/nix/pkgs/kube-score" {};
          kustomize = (import (fetchFromGitHub versions.nixpkgs-kustomize-1) {}).kustomize;
          telepresence = super.unstable.telepresence;
        }
      )
    ];
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    curl
    dep
    direnv
    docker-compose
    go
    google-cloud-sdk
    jq
    kube-score
    kubectl
    kubernetes-helm
    kustomize
    nodejs
    nodePackages.node-gyp
    python2Full
    rsync
    stdenv
    telepresence
    yarn
  ];
}
