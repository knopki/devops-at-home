{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.nixdev.enable = mkEnableOption "Nix developer pack";

  config = mkIf config.local.nixdev.enable {
    home.packages = with pkgs; [
      cachix
      nix-index
      nixpkgs-fmt
      nodePackages.node2nix
    ];
  };
}
