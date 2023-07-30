{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  programs.wofi = {
    enable = true;
    width = "40%";
    term = mkIf config.programs.alacritty.enable
      "${config.programs.alacritty.package}/bin/alacritty -e";
    allow_images = true;
    allow_markup = true;
    parse_search = true;
    no_actions = true;
    key_up = "Alt_L-k";
    key_down = "Alt_L-j";
    stylesheet = builtins.readFile ./wofi.css;
  };
}
