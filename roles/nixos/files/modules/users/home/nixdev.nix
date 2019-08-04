{ config, lib, pkgs, user, ... }:
with lib;
{
  options.local.nixdev.enable = mkEnableOption "Nix develper pack";

  config = mkIf config.local.nixdev.enable {
    home.packages = with pkgs; [
      nixfmt
      nodePackages.node2nix
    ];
  };
}
