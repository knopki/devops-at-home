{ config, lib, pkgs, ... }:
with lib; {
  options.knopki.alacritty = {
    enable = mkEnableOption "enable alacritty for user";
  };

  config = mkIf config.knopki.alacritty.enable {
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
          dynamic_title = true;
          scrolling = {
            history = 10000;
            auto_scroll = false;
          };
        };

        # Font configuration
        font = {
          normal = { family = "FiraCode Nerd Font Mono"; };
          size = 12;
          glyph_offset = {
            x = 0;
            y = -1;
          };
          use_thin_strokes = false;
        };

        background_opacity = 0.9;

        # key_bindings = { };
      };
    };
  };
}
