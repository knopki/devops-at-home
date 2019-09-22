{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.termite.enable = mkEnableOption "setup termite";

  config = mkIf config.local.termite.enable {
    programs.termite = {
      allowBold = true;
      audibleBell = false;
      backgroundColor = "rgba(40, 44, 52)";
      clickableUrl = true;
      colorsExtra = ''
        # OneDark
        # 16 color space
        # Black, Gray, Silver, White
        color0  = #282c34
        color8  = #545862
        color7  = #abb2bf
        color15 = #c8ccd4

        # Red
        color1  = #e06c75
        color9  = #e06c75

        # Green
        color2  = #98c379
        color10 = #98c379

        # Yellow
        color3  = #e5c07b
        color11 = #e5c07b

        # Blue
        color4  = #61afef
        color12 = #61afef

        # Purple
        color5  = #c678dd
        color13 = #c678dd

        # Teal
        color6  = #56b6c2
        color14 = #56b6c2

        # Extra colors
        color16 = #d19a66
        color17 = #be5046
        color18 = #353b45
        color19 = #3e4451
        color20 = #565c64
        color21 = #b6bdca
      '';
      cursorBlink = "system";
      cursorColor = "#b6bdca";
      cursorForegroundColor = "#282c34";
      cursorShape = "block";
      dynamicTitle = false;
      enable = true;
      filterUnmatchedUrls = true;
      font = "Fira Code 10";
      foregroundBoldColor = "#b6bdca";
      foregroundColor = "#abb2bf";
      fullscreen = true;
      hintsActiveBackgroundColor = "#3f3f3f";
      hintsActiveForegroundColor = "#e68080";
      hintsBackgroundColor = "#3f3f3f";
      hintsBorderColor = "#3f3f3f";
      hintsBorderWidth = "0.5";
      hintsFont = "Fira Code 12";
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
