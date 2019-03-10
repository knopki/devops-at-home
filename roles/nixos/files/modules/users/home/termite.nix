{ config, lib, pkgs, user, ... }:
with lib;
{
  options.local.termite.enable = mkEnableOption "setup termite";

  config = mkIf config.local.termite.enable {
    programs.termite = {
      allowBold = true;
      audibleBell = false;
      backgroundColor = "#2D2D2D";
      clickableUrl = true;
      colorsExtra = ''
        # Black, Gray, Silver, White
        color0  = #2d2d2d
        color8  = #747369
        color7  = #d3d0c8
        color15 = #f2f0ec

        # Red
        color1  = #f2777a
        color9  = #f2777a

        # Green
        color2  = #99cc99
        color10 = #99cc99

        # Yellow
        color3  = #ffcc66
        color11 = #ffcc66

        # Blue
        color4  = #6699cc
        color12 = #6699cc

        # Purple
        color5  = #cc99cc
        color13 = #cc99cc

        # Teal
        color6  = #66cccc
        color14 = #66cccc

        # Extra colors
        color16 = #f99157
        color17 = #d27b53
        color18 = #393939
        color19 = #515151
        color20 = #a09f93
        color21 = #e8e6df
      '';
      cursorBlink = "system";
      cursorColor = "#e8e6df";
      cursorForegroundColor = "#2d2d2d";
      cursorShape = "block";
      dynamicTitle = false;
      enable = true;
      filterUnmatchedUrls = true;
      font = "Hack Nerd Font 10";
      foregroundBoldColor = "#e8e6df";
      foregroundColor = "#d3d0c8";
      fullscreen = true;
      hintsActiveBackgroundColor = "#3f3f3f";
      hintsActiveForegroundColor = "#e68080";
      hintsBackgroundColor = "#3f3f3f";
      hintsBorderColor = "#3f3f3f";
      hintsBorderWidth = "0.5";
      hintsFont = "Hack Nerd Font 12";
      hintsForegroundColor = "#dcdccc";
      hintsPadding = 2;
      hintsRoundness = "2.0";
      iconName = "terminal";
      modifyOtherKeys = false;
      mouseAutohide = false;
      scrollbackLines = 100000;
      scrollbar = "off";
      scrollOnKeystroke = true;
      scrollOnOutput = false;
      searchWrap = true;
      sizeHints = false;
      urgentOnBell = false;
    };
  };
}
