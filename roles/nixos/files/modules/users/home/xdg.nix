{ config, lib, pkgs, user, ... }:
with lib;
{
  options.local.xdgDirs = mkEnableOption "setup xdg dirs";

  config = mkIf config.local.xdgDirs {
    xdg.enable = true;

    xdg.configFile = {
      "user-dirs.locale".text = "en_US";

      "user-dirs.dirs".text = ''
        XDG_DESKTOP_DIR="$HOME/desktop"
        XDG_DOWNLOAD_DIR="$HOME/downloads"
        XDG_TEMPLATES_DIR="$HOME/templates"
        XDG_PUBLICSHARE_DIR="$HOME/public"
        XDG_DOCUMENTS_DIR="$HOME/docs"
        XDG_MUSIC_DIR="$HOME/music"
        XDG_PICTURES_DIR="$HOME/pics"
        XDG_VIDEOS_DIR="$HOME/movies"
      '';
    };
  };
}
