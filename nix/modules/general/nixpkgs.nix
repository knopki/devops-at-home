{ config, lib, pkgs, ... }:
with lib;
let
  sources = import ../../sources.nix;
  rebuild-throw = pkgs.writeText "rebuild-throw.nix"
    ''throw "I'm sorry Dave, I'm afraid I can't do that... Please deploy this host with morph or specify NIX_PATH with nixos-config."'';
in
{
  imports = [ (import sources.nur {}).repos.rycee.modules.home-manager ];

  options = { local.general.nixpkgs.enable = mkEnableOption "Nixpkgs"; };

  config = mkIf config.local.general.nixpkgs.enable {
    nixpkgs = {
      config.allowUnfree = true;
      config.packageOverrides = pkgs: {
        nur = import sources.nur { inherit pkgs; };
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

    nix.nixPath = mkDefault (
      mkBefore [
        "${sources.nixpkgs}"
        "nixpkgs=${sources.nixpkgs}"
        "nixos-config=${rebuild-throw}"
      ]
    );

    environment.etc."nixos/configuration.nix".source = rebuild-throw;

    system.nixos.versionSuffix = mkDefault "";
  };
}
