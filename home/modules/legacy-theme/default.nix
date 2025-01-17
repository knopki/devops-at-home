{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.theme;
in
{
  imports = [
    ./theme-alacritty.nix
    ./theme-base16.nix
    ./theme-bat.nix
    ./theme-dircolors.nix
    ./theme-emacs.nix
    ./theme-fonts.nix
    ./theme-fzf.nix
    ./theme-gnome-terminal.nix
    ./theme-gtk.nix
    ./theme-neovim.nix
    ./theme-plasma.nix
    ./theme-shell.nix
    ./theme-tmux.nix
    ./theme-zathura.nix
  ];

  options.theme = {
    enable = mkEnableOption "Enable theme support";

    preset = mkOption {
      type = with types; nullOr (enum [ "dracula" ]);
      default = null;
      description = "Apply one of predefined presets.";
    };
  };

  config = mkIf cfg.enable { };
}
