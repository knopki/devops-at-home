{ config, pkgs, lib, ... }:
with lib;
with import <nixpkgs> {};
let
  versions = builtins.fromJSON (builtins.readFile ../../pkgs/versions.json);
  homeManager = fetchFromGitHub versions.home-manager;
  # waylandOverlay = fetchFromGitHub versions.nixpkgs-wayland;
in {
  imports = [
    "${homeManager}/nixos"
  ];

  options = {
    local.general.nixpkgs.enable = mkEnableOption "Nixpkgs";
  };

  config = mkIf config.local.general.nixpkgs.enable {
    nixpkgs = {
      config.allowUnfree = true;

      pkgs = import (fetchFromGitHub versions.nixpkgs-stable) {
        config = config.nixpkgs.config;
        overlays = config.nixpkgs.overlays;
      };

      overlays = [
        (self: super: {
          unstable = import (fetchFromGitHub versions.nixpkgs-unstable) {
            config.allowUnfree = true;
          };
          nur = import (fetchFromGitHub versions.nur) {
            inherit super;
          };
          # wayland-server = super.unstable.wayland-server;
        })
        (self: super: {
          fish-theme-pure = pkgs.callPackage ../../pkgs/fish-theme-pure.nix {};
          kube-score = pkgs.callPackage ../../pkgs/kube-score {};
          wf-recorder = super.unstable.wf-recorder;
          wl-clipboard = super.unstable.wl-clipboard;
        })
        (import ../../pkgs/tmux-plugins.nix)
      ];
    };
  };
}
