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
        nur-knopki = import sources.nur-knopki { inherit pkgs; };
        # nur-knopki = import ../../../../nixexprs { inherit pkgs; };
      };

      pkgs = import sources.nixpkgs {
        config = config.nixpkgs.config;
        overlays = config.nixpkgs.overlays;
      };

      overlays = [
        (
          self: super: {
            fish-kubectl-completions = super.nur-knopki.fishPlugins.completions.kubectl;
            fish-theme-pure = super.nur-knopki.fishPlugins.pure;
            gnvim = super.unstable.gnvim;
            localVimPlugins = super.callPackage ../../pkgs/vimPlugins.nix {};
            neovim-gtk = super.nur.repos.n1kolasM.neovim-gtk;
            neovim-unwrapped = super.unstable.neovim-unwrapped;
            nix-direnvrc = "${sources.nix-direnv}/direnvrc";
            trapd00r-ls-colors =
              super.callPackage ../../pkgs/trapd00r-ls-colors.nix {};
            waybar = super.waybar.override { pulseSupport = true; };
            winbox = super.nur-knopki.winbox-bin;
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
