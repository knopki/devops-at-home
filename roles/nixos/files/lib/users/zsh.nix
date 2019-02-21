{ config, pkgs, username, lib, ...}:
let
  selfHM = config.home-manager.users."${username}";
  zshFunctions = (import ./zsh-functions.nix);
in with builtins;
{
  home.file = lib.mkMerge (
    map (x: {
      "${selfHM.programs.zsh.dotDir}/functions/${x}".text = zshFunctions.${x};
    }) [
      "cdf" "fcd" "fda" "fdr" "fe" "fgshow" "fgstash" "fh" "fkill" "fo" "gb"
      "gf" "gh" "gr" "gt" "is_in_git_repo" "save_pwd" "source_if_possible"
    ]
  );

  programs.fzf.enableZshIntegration = true;

  programs.zsh = {
    dotDir = ".config/zsh";
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;

    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      path = ".local/share/zsh/history/history.$(date +%Y).$(whoami)@$(hostname -s)";
      save = 100000000;
      share = true;
      size = 100000000;
    };

    profileExtra = ''
      emulate sh -c 'source ~/.profile'
    '';

    shellAliases = {
      _fzf_complete_gopass = "_fzf_complete_pass";
      fzf = "fzf-tmux -m";
      gmpv = "flatpak run --filesystem=xdg-download io.github.GnomeMpv --enqueue";
      grep = "grep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
      history = "fc -il 1";
      ls = "ls --color=auto";
      man = "nocorrect man";
      mv = "nocorrect mv";
      o = "xdg-open";
      rsync-copy = "rsync -avz --progress -h";
      rsync-move = "rsync -avz --progress -h --remove-source-files";
      rsync-synchronize = "rsync -avzu --delete --progress -h";
      rsync-update = "rsync -avzu --progress -h";
      sudo = "nocorrect sudo";
      svim = "sudo -E vim";
    };
  };
}
