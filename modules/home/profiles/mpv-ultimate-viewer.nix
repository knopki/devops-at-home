{
  lib,
  pkgs,
  packages,
  ...
}:
let
  inherit (builtins) typeOf;
  inherit (lib) generators mapAttrs' nameValuePair;

  renderOption =
    option:
    rec {
      int = toString option;
      float = int;
      bool = lib.hm.booleans.yesNo option;
      string = option;
    }
    .${typeOf option};
  renderScriptOptions = generators.toKeyValue {
    mkKeyValue = generators.mkKeyValueDefault { mkValueString = renderOption; } "=";
    listsAsDuplicateKeys = true;
  };
in
{
  programs.mpv = {
    enable = true;
    package = (
      pkgs.mpv.override {
        scripts =
          with pkgs;
          with pkgs.mpvScripts;
          with packages;
          [
            autoload
            thumbfast
            uosc
            mpv-align-images
            mpv-image-bindings
          ];
      }
    );
    # package = pkgs.wrapMpv packages.mpv-unwrapped {
    #   scripts =
    #     with packages;
    #     with pkgs.mpvScripts;
    #     [
    #       autoload
    #       thumbfast
    #       uosc
    #       mpv-align-images
    #       mpv-image-bindings
    #     ];
    # };
    config = {
      osd-bar = "no";
      border = "no";
      slang = "ru,rus,en,eng";
      alang = "ru,rus,en,eng";
      sub-auto = "all";
      keep-open = "yes";

      vo = "gpu-next";
      image-display-duration = "inf";
      reset-on-next-file = "video-rotate,video-zoom,panscan";
      prefetch-playlist = "";
      loop-playlist = "";
      # input-preprocess-wheel = "no"; # pan diagonally with a touchpad
      force-window-position = ""; # recenter the window when changing playlist position on X11
      auto-window-resize = "no"; # preserve the window size when changing playlist entry
      autofit = "100%x100%"; # fit the window in the display
    };
    profiles = {
      fullscreen = {
        profile-cond = "video_unscaled or video_zoom > 0 or panscan > 0";
        profile-restore = "copy";
        fullscreen = "";
      };

      image = {
        profile-cond = "p['current-tracks/video/image'] and not p['current-tracks/video/albumart'] and mp.command('enable-section image')";
        profile-restore = "copy";
        osc = "no";
        linear-downscaling = "no"; # don't make black and white manga brighter
      };

      video = {
        profile-cond = "p['current-tracks/video/image'] == false and mp.command('disable-section image')";
        profile-restore = "copy";
      };

      loop-short = {
        profile-cond = "duration < 30 and p['current-tracks/video/image'] == false and image_display_duration == math.huge";
        loop-file = "";
      };
    };
    # defaultProfiles = [];
    bindings = {
      # These are useful for both videos and images.
      r = "cycle-values video-rotate 270 180 90 0"; # default: add sub-pos -1
      t = "cycle-values video-rotate 90 180 270 0"; # default: add sub-pos +1
      v = "cycle-values video-rotate 0 180"; # default: cycle sub-visibility

      # Enter a playlist index to go to.
      "Alt+g" = "script-message-to console type 'set playlist-pos-1 ; keypress ESC' 20";
      # Go to the first playlist entry.
      "Ctrl+g" = "playlist-play-index 0";
      # Go to the last playlist entry.
      # TODO: doesn't work
      G = "no-osd set playlist-pos-1 \${playlist-count}"; # default: add sub-scale +0.1

      # Image-only bindings

      SPACE = "{image} repeatable playlist-next force";
      "Ctrl+SPACE" = "{image} repeatable playlist-prev force";

      "Ctrl+>" =
        "{image} repeatable playlist-next; playlist-next; playlist-next; playlist-next; playlist-next; playlist-next; playlist-next; playlist-next; playlist-next; playlist-next";
      "Ctrl+<" =
        "{image} repeatable playlist-prev; playlist-prev; playlist-prev; playlist-prev; playlist-prev; playlist-prev; playlist-prev; playlist-prev; playlist-prev; playlist-prev";

      "Ctrl+r" = "{image} playlist-shuffle; playlist-next; playlist-unshuffle";

      # pan-image is a wrapper around altering video-align that pans
      # relatively to the window's dimensions instead of the image's.
      # +1 scrolls one screen width/height.
      h = "{image} repeatable script-message pan-image x -.2";
      j = "{image} repeatable script-message pan-image y +.2";
      k = "{image} repeatable script-message pan-image y -.2";
      l = "{image} repeatable script-message pan-image x +.2";
      LEFT = "{image} repeatable script-message pan-image x -.2";
      DOWN = "{image} repeatable script-message pan-image y +.2";
      UP = "{image} repeatable script-message pan-image y -.2";
      RIGHT = "{image} repeatable script-message pan-image x +.2";
      H = "{image} repeatable script-message pan-image x -.02";
      J = "{image} repeatable script-message pan-image y +.02";
      K = "{image} repeatable script-message pan-image y -.02";
      L = "{image} repeatable script-message pan-image x +.02";
      "Shift+LEFT" = "{image} repeatable script-message pan-image x -.02";
      "Shift+DOWN" = "{image} repeatable script-message pan-image y +.02";
      "Shift+UP" = "{image} repeatable script-message pan-image y -.02";
      "Shift+RIGHT" = "{image} repeatable script-message pan-image x +.02";

      # Align the image to the window's boundaries.
      "Ctrl+h" = "{image} no-osd set video-align-x -1";
      "Ctrl+j" = "{image} no-osd set video-align-y 1";
      "Ctrl+k" = "{image} no-osd set video-align-y -1";
      "Ctrl+l" = "{image} no-osd set video-align-x 1";
      "Ctrl+LEFT" = "{image} no-osd set video-align-x -1";
      "Ctrl+DOWN" = "{image} no-osd set video-align-y 1";
      "Ctrl+UP" = "{image} no-osd set video-align-y -1";
      "Ctrl+RIGHT" = "{image} no-osd set video-align-x 1";

      "9" = "{image} add video-zoom +.25"; # easier to reach than =
      "-" = "{image} add video-zoom -.25";
      "(" = "{image} add video-zoom +.05";
      "_" = "{image} add video-zoom -.05";
      "0" = "{image} no-osd set video-zoom 0; no-osd set panscan 0";
      # Toggle scaling the image to the window.
      "u" =
        "{image} no-osd cycle-values video-unscaled yes no; no-osd set video-zoom 0; no-osd set panscan 0";
      # cycle video-unscaled will also cycle through downscale-big.
      # autofit=100%x100% makes the window bigger than necessary with downscale-big
      # though so you may want to replace it with autofit-larger=100%x100%

      # panscan crops scaled videos with different aspect ratio than the window.
      # At 1 it fills black bars completely.
      o = "{image} no-osd set panscan 1; no-osd set video-unscaled no; no-osd set video-zoom 0";

      # Toggle slideshow mode.
      s = "{image} cycle-values image-display-duration 1 inf; no-osd set video-zoom 0; no-osd set panscan 0; no-osd set video-unscaled no";

      # Show the current image next to the previous one. This is automatically
      # disabled when changing playlist position. For something more complex, use
      # https://github.com/Dudemanguy/mpv-manga-reader
      d = "{image} script-message double-page-mode";

      # This mouse gesture executes one of 5 commands configured in
      # script-opts/image_bindings.conf depending on the direction you drag the
      # mouse. To use it without an input section you need window-dragging=no in
      # mpv.conf.
      MBTN_LEFT = "{image} script-binding gesture";
      # Don't double click by accident.
      MBTN_LEFT_DBL = "{image} ignore";

      # Pan the image while holding a mouse button, relative to the clicked point in the window.
      MBTN_RIGHT = "{image} script-binding drag-to-pan";

      # Pan the image while holding a mouse button, relative to the whole image.
      MBTN_MID = "{image} script-binding align-to-cursor";

      # Zoom towards where the cursor is hovering.
      # WHEEL_UP   = "{image} script-message cursor-centric-zoom .1";
      # WHEEL_DOWN = "{image} script-message cursor-centric-zoom -.1";

      # On a touchpad:
      WHEEL_UP = "{image} script-message pan-image y -.05";
      WHEEL_DOWN = "{image} script-message pan-image y .05";
      WHEEL_LEFT = "{image} script-message pan-image x -.05";
      WHEEL_RIGHT = "{image} script-message pan-image x .05";
      "Ctrl+WHEEL_UP" = "{image} script-message cursor-centric-zoom .1";
      "Ctrl+WHEEL_DOWN" = "{image} script-message cursor-centric-zoom -.1";
    };
  };
  xdg.configFile =
    mapAttrs'
      (name: value: nameValuePair "mpv/script-opts/${name}.conf" { text = renderScriptOptions value; })
      {
        autoload = {
          ignore_hidden = "yes";
          directory_mode = "recursive";
          # ignore_patterns = "^~,^bak-,%.bak$,.score";
        };
        align_images = {
          # The video-align-x value to set for images larger than the window.
          # 1 aligns them to the right, which is useful for manga, and -1 to the left.
          # This can be changed depending on the path in conditional profiles like so:
          # script-opts-append=detect_image-align_x=-1
          align_x = "1";
        };
        image_bingins = {
          # gesture_click is executed when you don't drag anywhere.
          gesture_click = "playlist-next force";
          gesture_up = "no-osd set video-zoom 0";
          gesture_right = "no-osd cycle-values video-unscaled yes no; no-osd set video-zoom 0";
          gesture_down = "script-message playlist-view-open";
          gesture_left = "playlist-prev";
        };
      };
}
