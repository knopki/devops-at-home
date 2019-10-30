{ config, lib, pkgs, ... }:
with lib;
let
  sources = import ../../sources.nix;
  nur-no-pkgs = import sources.nur {
    repoOverrides = {
      knopki = import sources.nur-knopki {};
      # knopki = import ../../../../nixexprs { };
    };
  };
in
{
  imports = [
    nur-no-pkgs.repos.knopki.modules.nix
    nur-no-pkgs.repos.rycee.modules.home-manager
  ];

  options = { local.general.nixpkgs.enable = mkEnableOption "Nixpkgs"; };

  config = mkIf config.local.general.nixpkgs.enable {
    nixpkgs = {
      config.allowUnfree = true;
      config.packageOverrides = pkgs: {
        nur = import sources.nur {
          inherit pkgs;
          repoOverrides = {
            knopki = import sources.nur-knopki { inherit pkgs; };
            # knopki = import ../../../../nixexprs { inherit pkgs; };
          };
        };
        unstable = import sources.nixpkgs-unstable {
          config.allowUnfree = true;
        };
      };

      pkgs = import sources.nixpkgs {
        config = config.nixpkgs.config;
        overlays = config.nixpkgs.overlays;
      };

      overlays = [
        (
          self: super: {
            fish-kubectl-completions = super.nur.repos.knopki.fishPlugins.completions.kubectl;
            fish-theme-pure = super.nur.repos.knopki.fishPlugins.pure;
            gnvim = super.unstable.gnvim;
            localVimPlugins = super.nur.repos.knopki.vimPlugins;
            neovim-gtk = super.nur.repos.n1kolasM.neovim-gtk;
            neovim-unwrapped = super.unstable.neovim-unwrapped;
            nix-direnvrc = "${sources.nix-direnv}/direnvrc";
            trapd00r-ls-colors = super.nur.repos.knopki.lsColors;
            waybar = super.waybar.override { pulseSupport = true; };
            winbox = super.nur.repos.knopki.winbox-bin;
          }
        )
      ];
    };
  };
}
