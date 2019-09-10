{ config, nixosConfig, lib, pkgs, user, ... }:
with lib; {
  options.local.alacritty = {
    enable = mkEnableOption "enable alacritty for user";
  };

  config = mkIf config.local.alacritty.enable {
    programs.alacritty = {
      enable = true;

      # Reference:
      # https://raw.githubusercontent.com/jwilm/alacritty/master/alacritty.yml
      settings = {
        env = {
          # This value is used to set the `$TERM` environment variable for
          # each instance of Alacritty. If it is not present, alacritty will
          # check the local terminfo database and use `alacritty` if it is
          # available, otherwise `xterm-256color` is used.
          TERM = "xterm-256color";
        };

        window = {
          scrolling = {
            history = 10000;
            auto_scroll = false;
          };
        };

        # Font configuration
        font = {
          normal = { family = "FuraCode Nerd Font Mono"; };
          size = 12;
          glyph_offset = {
            x = 0;
            y = -1;
          };
          use_thin_strokes = false;
        };

        # If `true`, bold text is drawn using the bright color variants.
        draw_bold_text_with_bright_colors = true;

        # One Dark theme
        colors = {
          primary = {
            background = "0x1e2127";
            foreground = "0xabb2bf";
          };

          normal = {
            black = "0x1e2127";
            red = "0xe06c75";
            green = "0x98c379";
            yellow = "0xd19a66";
            blue = "0x61afef";
            magenta = "0xc678dd";
            cyan = "0x56b6c2";
            white = "0xabb2bf";
          };

          bright = {
            black = "0x5c6370";
            red = "0xe06c75";
            green = "0x98c379";
            yellow = "0xd19a66";
            blue = "0x61afef";
            magenta = "0xc678dd";
            cyan = "0x56b6c2";
            white = "0xffffff";
          };
        };

        visual_bell = {
          animation = "EaseOutExpo";
          duration = 100;
          color = "0x4a5263";
        };

        background_opacity = 0.9;

        dynamic_title = true;

        # key_bindings = { };
      };
    };
  };
}
