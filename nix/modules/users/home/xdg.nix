{ config, lib, pkgs, user, ... }:
with lib;
let
  cfg = config.xdg.userDirs;
in {
  config = mkIf cfg.enable {
    home.file = mkMerge (map (x: { "${x}/.keep".text = ""; }) [
      cfg.desktop
      cfg.documents
      cfg.download
      cfg.music
      cfg.pictures
      cfg.publishShare
      cfg.templates
      cfg.videos
    ]);
  };
}
