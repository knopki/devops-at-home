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

      pkgs = import sources.nixpkgs {
        config = config.nixpkgs.config;
        overlays = config.nixpkgs.overlays;
      };

      overlays = [
        (
          self: super: {
            nur = import sources.nur {
              inherit pkgs;
              repoOverrides = {
                knopki = import sources.nur-knopki { inherit pkgs; };
                # knopki = import ../../../../nixexprs { inherit pkgs; };
              };
            };
            unstable = import sources.nixpkgs-unstable { config.allowUnfree = true; };
          }
        )
        nur-no-pkgs.repos.knopki.overlays.fishPlugins
        nur-no-pkgs.repos.knopki.overlays.lsColors
        nur-no-pkgs.repos.knopki.overlays.nix-direnv
        nur-no-pkgs.repos.knopki.overlays.vimPlugins
        nur-no-pkgs.repos.knopki.overlays.waybar
        nur-no-pkgs.repos.knopki.overlays.winbox
        (
          self: super: {
            neovim-gtk = super.nur.repos.n1kolasM.neovim-gtk;
            neovim-unwrapped = super.unstable.neovim-unwrapped;
          }
        )
      ];
    };
  };
}
