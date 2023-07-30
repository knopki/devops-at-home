{ pkgs, lib, config, nixosConfig, ... }:
let
  inherit (lib) mkDefault mkIf;
in
{
  home.packages = with pkgs.fishPlugins; [ foreign-env ];

  programs.fish = {
    enable = mkDefault true;

    functions = {
      fish_hybrid_key_bindings = {
        description = "Vi-style bindings that inherit emacs-style bindings in all modes";
        body = ''
          for mode in default insert visual
              fish_default_key_bindings -M $mode
          end
          fish_vi_key_bindings --no-erase
          bind --user \e\[3\;5~ kill-word  # Ctrl-Delete
        '';
      };
    };

    interactiveShellInit = ''
      # keybindings
      set -g fish_key_bindings fish_hybrid_key_bindings

      # disable greeting
      set -u fish_greeting ""
    '';

    shellAbbrs = {
      gco = "git checkout";
      gst = "git status";
      o = "xdg-open";
      e = mkIf config.programs.doom-emacs.enable "emacs -nw";
    };

    shellAliases = {
      fzf = "fzf-tmux -m";
      grep = "grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
      myip = "curl ifconfig.co";
      rsync-copy = "rsync -avz --progress -h";
      rsync-move = "rsync -avz --progress -h --remove-source-files";
      rsync-synchronize = "rsync -avzu --delete --progress -h";
      rsync-update = "rsync -avzu --progress -h";
    };
  };
}
