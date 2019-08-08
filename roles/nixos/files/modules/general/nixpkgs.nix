{ config, pkgs, lib, ... }:
with lib;
with import <nixpkgs> { };
let
  versions = builtins.fromJSON (builtins.readFile ../../pkgs/versions.json);
  homeManager = fetchFromGitHub versions.home-manager;
  nixpkgsSrcStable = fetchFromGitHub versions.nixpkgs-stable;
in {
  imports = [ "${homeManager}/nixos" ];

  options = { local.general.nixpkgs.enable = mkEnableOption "Nixpkgs"; };

  config = mkIf config.local.general.nixpkgs.enable {
    nixpkgs = {
      config.allowUnfree = true;

      pkgs = import "${nixpkgsSrcStable}" {
        config = config.nixpkgs.config;
        overlays = config.nixpkgs.overlays;
      };

      overlays = [
        (self: super: {
          unstable = import (fetchFromGitHub versions.nixpkgs-unstable) {
            config.allowUnfree = true;
          };
          nur = import (fetchFromGitHub versions.nur) { inherit super; };
        })
        (self: super: {
          fish-kubectl-completions =
            pkgs.callPackage ../../pkgs/fish-kubectl-completions.nix { };
          fish-theme-pure = pkgs.callPackage ../../pkgs/fish-theme-pure.nix { };
          kube-score = pkgs.callPackage ../../pkgs/kube-score { };
          nixfmt = import (fetchFromGitHub versions.nixfmt) { };
          trapd00r-ls-colors =
            pkgs.callPackage ../../pkgs/trapd00r-ls-colors.nix { };
          wf-recorder = super.unstable.wf-recorder;
          wl-clipboard = super.unstable.wl-clipboard;
        })
        (import ../../pkgs/tmux-plugins.nix)
      ];
    };

    nix.nixPath = [
      "nixpkgs=${nixpkgsSrcStable}:nixos-config=/etc/nixos/configuration.nix"
    ];
  };
}
