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
    ./theme-base16.nix
    ./theme-emacs.nix
    ./theme-fonts.nix
    ./theme-fzf.nix
    ./theme-gnome-terminal.nix
    ./theme-gtk.nix
    ./theme-neovim.nix
    ./theme-plasma.nix
    ./theme-tmux.nix
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
