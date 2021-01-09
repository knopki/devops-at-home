{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  isWorkstation = nixosConfig.meta.tags.isWorkstation;
in
{
  imports = import ./list.nix;

  home = {
    stateVersion = mkDefault nixosConfig.system.stateVersion;
  };

  knopki = {
    bash.enable = true;
    curl.enable = true;
    fish.enable = true;
    git.enable = true;
    htop.enable = true;
    fzf.enable = isWorkstation;
    readline.enable = true;
    starship.enable = isWorkstation;
    ssh.enable = true;
    tmux.enable = true;
    wget.enable = true;
    zathura.enable = isWorkstation;
  };

  programs = {
    bat.enable = true;
    jq.enable = true;
    lesspipe.enable = true;
  };
}
