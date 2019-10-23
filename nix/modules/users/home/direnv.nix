{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.direnv = {
    enable = mkEnableOption "create root editorconfig";
  };

  config = mkIf config.local.direnv.enable {
    home.packages = with pkgs; [ direnv ];
    home.file.".direnvrc".source = pkgs.nix-direnvrc;
  };
}
