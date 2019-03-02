{ config, pkgs, lib, ... }:
with lib;
let
  homeManager = import ../../overlays/home-manager.nix;
  nixpkgsUnstable = import ../../overlays/nixpkgs-unstable.nix;
  nixpkgsWayland = import ../../overlays/nixpkgs-wayland.nix;
  nur = import ../../overlays/nur.nix;
  tmuxPlugins = import ../../overlays/tmux-plugins.nix;
  vscodeExts = import ../../overlays/vscode-with-extensions.nix;
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

      pkgs = import (import ../../overlays/nixpkgs-stable.nix) {
        config = config.nixpkgs.config;
        overlays = config.nixpkgs.overlays;
      };

      overlays = [
        nixpkgsUnstable
        nixpkgsWayland
        nur
        tmuxPlugins
        vscodeExts
        (self: super: {
          fish = super.unstable.fish;
          fish-theme-pure = pkgs.callPackage ../../overlays/fish-theme-pure.nix {};
          grim = super.grim.override {
            meson = super.unstable.meson;
          };
          kube-score = pkgs.callPackage ../../overlays/kube-score { };
          mako = super.mako.override {
            meson = super.unstable.meson;
          };
          sway = super.unstable.sway-beta;
          slurp = super.slurp.override {
            meson = super.unstable.meson;
          };
        })
      ];
    };
  };
}
