{ config, lib, pkgs, nixosConfig, ... }:
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
            name = "fish-kubectl-completions";
            src = nixosConfig.nix.registry.fish-kubectl-completions.flake.outPath;
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
