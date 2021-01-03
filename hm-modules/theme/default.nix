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
    ./gnome-terminal.nix
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
