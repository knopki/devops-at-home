{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.fish.enable = mkEnableOption "enable fish shell for user";

  config = mkIf config.knopki.fish.enable {
    programs = {
      fish = {
        enable = true;
        plugins = [
          {
            name = "colored_man_pages.fish";
            src = pkgs.fetchFromGitHub {
              owner = "patrickf3139";
              repo = "colored_man_pages.fish";
              rev = "b3048412273117c801ed9ae3bb253f3b6df63a8b";
              sha256 = "sha256-OkaizgqK1YMt5KfsTsiw2YnaSYqZtUP712Kk8fUD4mM=";
            };
          }
          {
            name = "fish-kubectl-completions";
            src = pkgs.fetchFromGitHub {
              owner = "evanlucas";
              repo = "fish-kubectl-completions";
              rev = "dadbc6e8d32652e0e5c49a42cdb38c0a667b3dfb";
              sha256 = "sha256-iE9sfZayRrFB2r9ywSAWHqmIWDxBhSD34p0dgZvh1Qs=";
            };
          }
        ];
        interactiveShellInit = ''
          # init foreign env
          set -p fish_function_path ${pkgs.fish-foreign-env}/share/fish-foreign-env/functions

          # keybindings
          bind --user \e\[3\;5~ kill-word  # Ctrl-Delete
          fish_vi_key_bindings

          # add fish man pages
          set -xg MANPATH "${pkgs.fish}/share/fish/man:$MANPATH"
        '';
        shellAbbrs = {
          gco = "git checkout";
          gst = "git status";
          o = "xdg-open";
          e = mkIf config.programs.emacs.enable "emacs -nq";
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
    };
  };
}
