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
    zathura.enable = isWorkstation;
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
        "EDITOR"
        "GIO_EXTRA_MODULES"
        "GTK_USE_PORTAL"
        "LANG"
        "LC_MONETARY"
        "LC_TIME"
        "NAUTILUS_EXTENSION_DIR"
        "NIX_GSETTINGS_OVERRIDES_DIR"
        "PASSWORD_STORE_DIR"
        "PASSWORD_STORE_KEY"
        "QT_QPA_PLATFORMTHEME"
        "SSH_ASKPASS"
        "SSH_AUTH_SOCK"
        "VISUAL"
        "XCURSOR_PATH"
        "XDG_CACHE_HOME"
        "XDG_CONFIG_DIRS"
        "XDG_CONFIG_HOME"
        "XDG_DATA_DIRS"
        "XDG_DATA_HOME"
        "XDG_DESKTOP_PORTAL_DIR"
      ]
    ) (nixosConfig.environment.variables // config.home.sessionVariables);
}
