{ config, lib, pkgs, ... }:
with lib;
let
  color00 = "#282c34";
  color01 = "#353b45";
  color02 = "#3e4451";
  color03 = "#545862";
  color04 = "#565c64";
  color05 = "#abb2bf";
  color06 = "#b6bdca";
  color07 = "#c8ccd4";
  color08 = "#e06c75";
  color09 = "#d19a66";
  color0A = "#e5c07b";
  color0B = "#98c379";
  color0C = "#56b6c2";
  color0D = "#61afef";
  color0E = "#c678dd";
  color0F = "#be5046";
in
{
  options.knopki.fzf = { enable = mkEnableOption "enable fzf for user"; };

  config = mkIf config.knopki.fzf.enable {
    home.packages = with pkgs; [ fd fzf ];

    programs.fzf = {
      enable = true;
      defaultOptions = [
        "--color=bg+:${color01},bg:${color00},spinner:${color0C},hl:${color0D}"
        "--color=fg:${color04},header:${color0D},info:${color0A},pointer:${color0C}"
        "--color=marker:${color0C},fg+:${color06},prompt:${color0A},hl+:${color0D}"
      ];
      defaultCommand = "${pkgs.fd}/bin/fd --type f";
      fileWidgetOptions = [ " --preview 'head {}'" ];
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
      changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    };
  };
}
