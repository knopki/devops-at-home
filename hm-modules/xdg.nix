{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.xdg.userDirs;
in
{
  config = mkIf cfg.enable {
    home.file = mkMerge (
      map (x: { "${x}/.keep".text = ""; }) [
        cfg.desktop
        cfg.documents
        cfg.download
        cfg.music
        cfg.pictures
        cfg.publicShare
        cfg.templates
        cfg.videos
      ]
    );
  };
}
