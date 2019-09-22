{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.desktop-pack.enable = mkEnableOption "install desktop apps";

  config = mkIf config.local.desktop-pack.enable {
    home.packages = with pkgs; [
      anki
      blender
      darktable
      feh
      gimp
      krita
      libreoffice
      neovim-gtk
      neovim-qt
      mpv
      pavucontrol
      picard
      playerctl
      skypeforlinux
      tdesktop
      tor-browser-bundle-bin
      transmission-gtk
      wine
      xdg_utils
      youtube-dl
    ];
  };
}
