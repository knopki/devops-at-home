{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.kitty = { enable = mkEnableOption "enable kitty for user"; };

  config = mkIf config.local.kitty.enable {
    home.packages = with pkgs; [ kitty ];

    home.file = {
      "${config.xdg.configHome}/kitty/kitty.conf".text = ''
        font_family FuraCode Nerd Font Mono
        font_size 12.0

        scrollback_lines 10000
        strip_trailing_spaces smart
        remember_window_size  no
        enabled_layouts stack
        hide_window_decorations yes
        update_check_interval 0

        term xterm-256color

        # Base16 OneDark - kitty color config
        # Scheme by Lalit Magant (http://github.com/tilal6991)
        background #282c34
        foreground #abb2bf
        selection_background #abb2bf
        selection_foreground #282c34
        url_color #565c64
        cursor #abb2bf
        active_border_color #545862
        inactive_border_color #353b45
        active_tab_background #282c34
        active_tab_foreground #abb2bf
        inactive_tab_background #353b45
        inactive_tab_foreground #565c64

        # normal
        color0 #282c34
        color1 #e06c75
        color2 #98c379
        color3 #e5c07b
        color4 #61afef
        color5 #c678dd
        color6 #56b6c2
        color7 #abb2bf

        # bright
        color8 #545862
        color9 #e06c75
        color10 #98c379
        color11 #e5c07b
        color12 #61afef
        color13 #c678dd
        color14 #56b6c2
        color15 #abb2bf

        # extended base16 colors
        color16 #d19a66
        color17 #be5046
        color18 #353b45
        color19 #3e4451
        color20 #565c64
        color21 #b6bdca
      '';
    };
  };
}

