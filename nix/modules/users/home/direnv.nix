{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.direnv = {
    enable = mkEnableOption "create root editorconfig";
  };

  config = mkIf config.local.direnv.enable {
    home.packages = with pkgs; [ direnv nix-direnv ];
    home.file.".direnvrc".text = ''
      #!/usr/bin/env bash
      source "${pkgs.nix-direnv}/direnvrc"
    '';
  };
}
