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
      curl.enable = true;
      desktop-pack.enable = isWorkstation;
      editorconfig = true;
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
      git.enable = true;
      htop.enable = true;
      readline.enable = true;
      ssh.enable = true;
      wget.enable = true;
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
