{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.theme;
in
{
  imports = [
    ./alacritty.nix
    ./base16.nix
    ./bat.nix
    ./doom-emacs.nix
    ./fonts.nix
    ./fzf.nix
    ./gnome-terminal.nix
    ./gtk.nix
    ./ls-colors.nix
    ./mako.nix
    ./neovim.nix
    ./shell.nix
    ./swaywm.nix
    ./tmux.nix
    ./vscode.nix
    ./waybar.nix
    ./wofi.nix
    ./zathura.nix
  ];

  options.theme = {
    enable = mkEnableOption "Enable theme support";

    preset = mkOption {
      type = types.nullOr (types.enum [ "dracula" ]);
      default = null;
      description = "Apply one of predefined presets.";
    };
  };

  config = mkIf cfg.enable { };
}
