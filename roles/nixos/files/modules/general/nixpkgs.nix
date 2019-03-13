{ config, pkgs, lib, ... }:
with lib;
with import <nixpkgs> {};
let
  versions = builtins.fromJSON (builtins.readFile ../../pkgs/versions.json);
  homeManager = fetchFromGitHub versions.home-manager;
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
        })
        (import (fetchFromGitHub versions.nixpkgs-wayland))
        (self: super: {
          fish = super.unstable.fish;
          fish-theme-pure = pkgs.callPackage ../../pkgs/fish-theme-pure.nix {};
          grim = super.grim.override {
            meson = super.unstable.meson;
          };
          kube-score = pkgs.callPackage ../../pkgs/kube-score { };
          mako = super.mako.override {
            meson = super.unstable.meson;
          };
          sway = super.unstable.sway-beta;
          slurp = super.slurp.override {
            meson = super.unstable.meson;
          };
        })
        (import ../../pkgs/tmux-plugins.nix)
      ];
    };
  };
}
