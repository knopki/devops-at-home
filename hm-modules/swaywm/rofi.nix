{ config, lib, pkgs, ... }:
with lib;
let
  rofiThemes = pkgs.fetchFromGitHub {
    owner = "davatorium";
    repo = "rofi-themes";
    rev = "e17b591590f0445fdc8ec1ff876f26d994e99bb4";
    sha256 = "sha256-ceP7qgDCdrXh3WjW1tioJrbJhuUwz8sb8vJLBptZ/Ng=";
  };
  theme = "${rofiThemes}/User Themes/onedark.rasi";
in
{
  config = mkIf config.knopki.swaywm.enable {
    programs.rofi = {
      inherit theme;
      enable = true;
      package = pkgs.rofi;
      font = "FiraCode Nerd Font Mono 10";
      terminal = "${pkgs.alacritty}/bin/alacritty";
    };
  };
}
