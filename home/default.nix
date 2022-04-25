{ inputs, config, lib, pkgs, ... }:
let
  inherit (inputs) digga;
in
{
  imports = [ (digga.lib.importExportableModules ./modules) ];
  modules = [
    { lib.our = inputs.self.lib; }
    inputs.nix-doom-emacs.hmModule
  ];
  importables = rec {
    profiles = digga.lib.rakeLeaves ./profiles;
    suites = with profiles; rec {
      base = [ hm ] ++ (with programs; [
        bash
        bat
        curl
        direnv
        fish
        fzf
        git
        htop
        jq
        lesspipe
        readline
        ssh
        tmux
        wget
      ]);

      graphical = base ++ [ desktop.gnome desktop.kde ] ++ (with programs; [
        alacritty
        firefox
        brave
        imv
        spectacle
        zathura
      ]);

      workstation = base ++ graphical ++ [
        ws-mods
        locale.ru-ru
      ] ++ (with programs; [
        password-store
        starship
        vscode
      ]);

      devbox = workstation ++ [
        services.hound
      ] ++ (with programs; [
        cloud-tools
        nodejs
        python
        winbox
      ]);

      gamestation = base ++ graphical ++ [
        locale.ru-ru
      ];
    };
  };
}
