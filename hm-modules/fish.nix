{ config, lib, pkgs, ... }:
with lib;
let
  base16-shell = pkgs.fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-shell";
    rev = "ce8e1e540367ea83cc3e01eec7b2a11783b3f9e1";
    sha256 = "sha256-OMhC6paqEOQUnxyb33u0kfKpy8plLSRgp8X8T8w0Q/o=";
  };
in
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
              owner = "PatrickF1";
              repo = "colored_man_pages.fish";
              rev = "b0e89f8d028388643dec59c6bc349b1e611da9bf";
              sha256 = "sha256-2LadTaxk+KvSEmsEXHjO0d6maTfFeOv7ew4/8HnDo3w=";
            };
          }
          {
            name = "fish-kubectl-completions";
            src = pkgs.fetchFromGitHub {
              owner = "evanlucas";
              repo = "fish-kubectl-completions";
              rev = "da5fa3c0dc254d37eb4b8e73a86d07c7bcebe637";
              sha256 = "sha256-7pR5/aQCkHct9lBx3u3nHmCAuo/V7XN1lC+ZvlRnNCo=";
            };
          }
        ];
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
          # init foreign env
          set -p fish_function_path ${pkgs.fish-foreign-env}/share/fish-foreign-env/functions

          # keybindings
          set -g fish_key_bindings fish_hybrid_key_bindings

          # disable greeting
          set -u fish_greeting ""

          # base16 one dark theme
          sh ${base16-shell}/scripts/base16-onedark.sh
        '';
        shellAbbrs = {
          gco = "git checkout";
          gst = "git status";
          o = "xdg-open";
          e = mkIf config.programs.emacs.enable "emacs -nw";
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
