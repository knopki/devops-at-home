{ config, lib, ... }:
with lib;
let
  envdDirPath = "${config.xdg.configHome}/environment.d";
  mapToText = mapAttrs (file: envAttrs: generators.toKeyValue {} envAttrs);
in
{
  options.knopki.env.graphics = mkEnableOption "setup graphics env vars";

  config = mkMerge [
    # add graphical variables
    (
      mkIf config.knopki.env.graphics {
        systemd.user.sessionVariables = {
          __GL_SHADER_DISK_CACHE_PATH = "${config.xdg.cacheHome}/nv";
          _JAVA_OPTIONS =
            "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel";
          CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
        };
      }
    )
  ];
}
