{ config, pkgs, username, lib, ...}:
let
  selfHM = config.home-manager.users."${username}";
in with builtins;
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # fix wrong terminfo for `termite`
      if test $TERM = "xterm-termite"
        set -x TERM "termite"
      end
    '';
    shellAbbrs = {
      o = "xdg-open";
      svim = "sudo -E vim";
    };
    shellAliases = {
      fzf = "fzf-tmux -m";
      gmpv = "flatpak run --filesystem=xdg-download io.github.GnomeMpv --enqueue";
      grep = "grep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
      ls = "ls --color=auto";
      rsync-copy = "rsync -avz --progress -h";
      rsync-move = "rsync -avz --progress -h --remove-source-files";
      rsync-synchronize = "rsync -avzu --delete --progress -h";
      rsync-update = "rsync -avzu --progress -h";
    };
  };
}
