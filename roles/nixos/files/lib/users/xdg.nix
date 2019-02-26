{ config, username, ... }:
let
  uid = builtins.toString config.users.users."${username}".uid;
in {
  home.sessionVariables = {
    XDG_RUNTIME_DIR = "\${XDG_RUNTIME_DIR:-/run/user/${uid}";
  };

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
}
