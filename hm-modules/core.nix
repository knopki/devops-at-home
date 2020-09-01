{ config, nixosConfig, lib, pkgs, ... }:
with lib;
let
  isWorkstation = config.meta.tags.isWorkstation;
in
{
  imports = import ./list.nix;

  knopki = {
    bash.enable = true;
    curl.enable = true;
    dircolors.enable = true;
    fish.enable = true;
    git.enable = true;
    htop.enable = true;
    fzf.enable = isWorkstation;
    readline.enable = true;
    starship.enable = isWorkstation;
    ssh.enable = true;
    tmux.enable = true;
    wget.enable = true;
  };

  programs = {
    bat.enable = true;
    jq.enable = true;
    lesspipe.enable = true;
  };
}
