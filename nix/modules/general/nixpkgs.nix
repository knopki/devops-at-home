{ config, lib, ... }:
with lib;
let
  sysPkgs = import <nixpkgs> {};
  fetchFromGitHub = sysPkgs.fetchFromGitHub;
  versions = builtins.fromJSON (builtins.readFile ../../pkgs/versions.json);
  nixpkgsSrcStable = fetchFromGitHub versions.nixpkgs-stable;
  nur-no-pkgs = import (fetchFromGitHub versions.nur) {};
  rebuild-throw = sysPkgs.writeText "rebuild-throw.nix"
    ''throw "I'm sorry Dave, I'm afraid I can't do that... Please deploy this host with morph or specify NIX_PATH with nixos-config."'';
in
{
  imports = [ nur-no-pkgs.repos.rycee.modules.home-manager ];

  options = { local.general.nixpkgs.enable = mkEnableOption "Nixpkgs"; };

  config = mkIf config.local.general.nixpkgs.enable {
    nixpkgs = {
      config.allowUnfree = true;
      config.packageOverrides = pkgs: {
        nur = import (fetchFromGitHub versions.nur) { inherit pkgs; };
        unstable = import (fetchFromGitHub versions.nixpkgs-unstable) {
          config.allowUnfree = true;
        };
      };

      pkgs = import "${nixpkgsSrcStable}" {
        config = config.nixpkgs.config;
        overlays = config.nixpkgs.overlays;
      };

      overlays = [
        (
          self: super: {
            fish-kubectl-completions =
              super.callPackage ../../pkgs/fish-kubectl-completions.nix {};
            fish-theme-pure = super.callPackage ../../pkgs/fish-theme-pure.nix {};
            gnvim = super.unstable.gnvim;
            localVimPlugins = super.callPackage ../../pkgs/vimPlugins.nix {};
            neovim-gtk = super.nur.repos.n1kolasM.neovim-gtk;
            neovim-unwrapped = super.unstable.neovim-unwrapped;
            trapd00r-ls-colors =
              super.callPackage ../../pkgs/trapd00r-ls-colors.nix {};
            waybar = super.waybar.override { pulseSupport = true; };
            winbox = super.callPackage ../../pkgs/winbox.nix {};
          }
        )
      ];
    };

    nix.nixPath = [
      "nixpkgs=${nixpkgsSrcStable}"
      "nixos-config=${rebuild-throw}"
    ];

    environment.etc."nixos/configuration.nix".source = rebuild-throw;
  };
}
