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

  # compat with wayland sessions
  systemd.user.sessionVariables = filterAttrs
    (
      k: v: builtins.elem k [
        "LC_MONETARY"
        "LC_TIME"
        "PASSWORD_STORE_DIR"
        "PASSWORD_STORE_KEY"
        "SSH_AUTH_SOCK"
        "XDG_CACHE_HOME"
        "XDG_CONFIG_HOME"
        "XDG_DATA_HOME"
      ]
    ) config.home.sessionVariables;
}
