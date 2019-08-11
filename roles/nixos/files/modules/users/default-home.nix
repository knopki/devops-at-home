{ config, lib, pkgs, ... }:
with lib;
let isWorkstation = config.local.roles.workstation.enable;
in {
  local.home-manager.config = {
    home.language.monetary = "ru_RU.UTF-8";
    home.language.time = "ru_RU.UTF-8";
    home.stateVersion = "19.03";
    nixpkgs.config = config.nixpkgs.config;
    nixpkgs.overlays = config.nixpkgs.overlays;
    local = {
      curl = true;
      desktop-pack.enable = isWorkstation;
      env.default = true;
      fish = {
        colorizeMan = true;
        defaultFuncs = true;
        fixTerm = true;
        loadProfile = true;
        lsColors = true;
        pureTheme = true;
        interactiveShellInit."99-binds" = ''
          bind --user \cw backward-kill-word # Ctrl-W
          bind --user \e\[3\;5~ kill-word  # Ctrl-Delete
        '';
      };
      git = true;
      htop = true;
      readline = true;
      ssh = true;
      wget = true;
      xdgUserDirs = {
        enable = isWorkstation;
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
