{ config, lib, pkgs, user, ... }:
with lib;
{
  options.local.desktop-pack.enable = mkEnableOption "install desktop apps";

  config = mkIf config.local.desktop-pack.enable {
    home.packages = with pkgs; [
      anki
      blender
      chromium
      darktable
      feh
      firefox
      gimp
      krita
      libreoffice-unwrapped
      mpv
      neovim-qt
      pavucontrol
      picard
      playerctl
      skypeforlinux
      tdesktop
      tor-browser-bundle-bin
      transmission-gtk
      wine
      youtube-dl
    ];
  };
}
