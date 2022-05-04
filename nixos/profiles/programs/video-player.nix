{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mkchromecast
    mpv
    vlc
  ];
}
