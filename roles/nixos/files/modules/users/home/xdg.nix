{ config, lib, pkgs, user, ... }:
with lib;
let
  dag = config.lib.dag;
  cfg = config.local.xdgUserDirs;
in {
  options.local = {
    xdgUserDirs = {
      enable = mkEnableOption "Customization of XDG user directories";

      locale = mkOption {
        type = types.str;
        default = "en_US";
      };

      desktop = mkOption {
        type = types.str;
        default = "Desktop";
      };
      documents = mkOption {
        type = types.str;
        default = "Documents";
      };
      download = mkOption {
        type = types.str;
        default = "Downloads";
      };
      music = mkOption {
        type = types.str;
        default = "Music";
      };
      pictures = mkOption {
        type = types.str;
        default = "Pictures";
      };
      publicshare = mkOption {
        type = types.str;
        default = "Public";
      };
      templates = mkOption {
        type = types.str;
        default = "Templates";
      };
      videos = mkOption {
        type = types.str;
        default = "Videos";
      };
    };
  };

  config = mkIf cfg.enable {
    xdg.enable = true;

    xdg.configFile."user-dirs.dirs".text = ''
      XDG_DESKTOP_DIR="${config.home.homeDirectory}/${cfg.desktop}"
      XDG_DOCUMENTS_DIR="${config.home.homeDirectory}/${cfg.documents}"
      XDG_DOWNLOAD_DIR="${config.home.homeDirectory}/${cfg.download}"
      XDG_MUSIC_DIR="${config.home.homeDirectory}/${cfg.music}"
      XDG_PICTURES_DIR="${config.home.homeDirectory}/${cfg.pictures}"
      XDG_PUBLICSHARE_DIR="${config.home.homeDirectory}/${cfg.publicshare}"
      XDG_TEMPLATES_DIR="${config.home.homeDirectory}/${cfg.templates}"
      XDG_VIDEOS_DIR="${config.home.homeDirectory}/${cfg.videos}"
    '';

    xdg.configFile."user-dirs.locale".text = cfg.locale;

    home.activation.xdgUserDirs = dag.entryAnywhere ''
      mkdir -p "${config.home.homeDirectory}/${cfg.desktop}"
      mkdir -p "${config.home.homeDirectory}/${cfg.documents}"
      mkdir -p "${config.home.homeDirectory}/${cfg.download}"
      mkdir -p "${config.home.homeDirectory}/${cfg.music}"
      mkdir -p "${config.home.homeDirectory}/${cfg.pictures}"
      mkdir -p "${config.home.homeDirectory}/${cfg.publicshare}"
      mkdir -p "${config.home.homeDirectory}/${cfg.templates}"
      mkdir -p "${config.home.homeDirectory}/${cfg.videos}"
    '';
  };
}
