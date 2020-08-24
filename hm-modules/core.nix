{ config, nixosConfig, lib, pkgs, ... }:
with lib;
{
  imports = import ./list.nix;

  knopki = {
    bash.enable = true;
    curl.enable = true;
    fish = {
      enable = true;
      colorizeMan = true;
      defaultFuncs = true;
      fixTerm = true;
      loadProfile = true;
      lsColors = true;
      pureTheme = true;
      interactiveShellInit."99-binds" = ''
        bind --user \cw backward-kill-word # Ctrl-W
        bind --user \e\[3\;5~ kill-word  # Ctrl-Delete
      '';
    };
    git.enable = true;
    htop.enable = true;
    readline.enable = true;
    ssh.enable = true;
    tmux.enable = true;
    wget.enable = true;
  };

  programs = {
    jq.enable = true;
    lesspipe.enable = true;
  };
}
