{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.kitty = { enable = mkEnableOption "enable kitty for user"; };

  config = mkIf config.local.kitty.enable {
    home.packages = with pkgs; [ kitty ];

    home.file = {
      "${config.xdg.configHome}/kitty/kitty.conf".text = ''
        font_family Fira Code
        font_size 12.0
        # symbol_map U+E0A0-U+E0A3,U+E0B0-U+E0BF,U+E0C0-U+E0C8,U+E0CC-U+E0CF,U+E0D0-U+E0D2,U+E0D4 PowerlineSymbols
        #  symbol_map U+E0A0-U+E0A2,U+E0B0-U+E0B3 PowerlineSymbols

        scrollback_lines 10000
        strip_trailing_spaces smart
        remember_window_size  no
        enabled_layouts stack
        hide_window_decorations yes
        update_check_interval 0

        term xterm-256color

        foreground #d3d0c8
        background #2D2D2D
        selection_foreground #3f3f3f
        selection_background #e68080

        # Black, Gray, Silver, White
        color0  #2d2d2d
        color8  #747369
        color7  #d3d0c8
        color15 #f2f0ec

        # Red
        color1  #f2777a
        color9  #f2777a

        # Green
        color2  #99cc99
        color10 #99cc99

        # Yellow
        color3  #ffcc66
        color11 #ffcc66

        # Blue
        color4  #6699cc
        color12 #6699cc

        # Purple
        color5  #cc99cc
        color13 #cc99cc

        # Teal
        color6  #66cccc
        color14 #66cccc

        # Extra colors
        color16 #f99157
        color17 #d27b53
        color18 #393939
        color19 #515151
        color20 #a09f93
        color21 #e8e6df
      '';
    };
  };
}

