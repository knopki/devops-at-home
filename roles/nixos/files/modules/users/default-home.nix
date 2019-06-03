{ config, lib, pkgs, ... }:
with lib;
{
  local.home-manager.config = {
    home.language.monetary = "ru_RU.UTF-8";
    home.language.time = "ru_RU.UTF-8";
    home.stateVersion = "19.03";
    nixpkgs.config = config.nixpkgs.config;
    nixpkgs.overlays = config.nixpkgs.overlays;
    local = {
      env.default = true;
      fish = {
        colorizeMan = true;
        defaultFuncs = true;
        fixTerm = true;
        loadProfile = true;
        pureTheme = true;
      };
      git = true;
      gpg-agent.defaults = true;
      readline = true;
      ssh = true;
      xdgUserDirs = {
        enable = true;
        desktop = "desktop";
        documents = "docs";
        download = "downloads";
        music = "music";
        pictures = "pics";
        publicshare = "public";
        templates = "templates";
        videos = "videos";
      };
    };
  };
}
