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
    nur-no-pkgs.repos.knopki.modules.profiles
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
        nur-no-pkgs.repos.knopki.overlays.allOverlays
        (
          self: super: {
            neovim-unwrapped = super.unstable.neovim-unwrapped;
          }
        )
      ];
    };
  };
}
