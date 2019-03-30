{ config, lib, user, ... }:
with lib;
let
  envdDirPath = "${config.xdg.configHome}/environment.d";
  mapToText = mapAttrs
    (file: envAttrs:
      generators.toKeyValue {} envAttrs);
in {
  options.local.env.default = mkEnableOption "setup default env vars";
  options.local.env.graphics = mkEnableOption "setup graphics env vars";

  config = mkMerge [
    # add default variables
    (mkIf config.local.env.default {
      home.sessionVariables = {
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${toString user.uid}/bus";
        EDITOR = "vim";
        VISUAL = "vim";
        XDG_RUNTIME_DIR = "/run/user/${toString user.uid}";
      };
      systemd.user.sessionVariables = {
        DBUS_SESSION_BUS_ADDRESS = "${config.home.sessionVariables.DBUS_SESSION_BUS_ADDRESS}";
        XDG_RUNTIME_DIR = "${config.home.sessionVariables.XDG_RUNTIME_DIR}";
      };
    })

    # add graphical variables
    (mkIf config.local.env.graphics {
      systemd.user.sessionVariables = {
        __GL_SHADER_DISK_CACHE_PATH = "${config.xdg.cacheHome}/nv";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel";
        CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
        SDL_VIDEODRIVER = "wayland";
      };
    })
  ];
}
