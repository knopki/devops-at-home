{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mkchromecast
    mpv-with-scripts
    vlc
  ];
}
