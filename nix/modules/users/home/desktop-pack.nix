{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.desktop-pack.enable = mkEnableOption "install desktop apps";

  config = mkIf config.local.desktop-pack.enable {
    home.packages = with pkgs; [
      anki
      blender
      chromaprint
      darktable
      feh
      gimp
      krita
      libreoffice
      nur.repos.n1kolasM.neovim-gtk
      mpv
      pavucontrol
      picard
      playerctl
      skypeforlinux
      tdesktop
      tor-browser-bundle-bin
      transmission-gtk
      xdg_utils
      youtube-dl
    ];
  };
}
