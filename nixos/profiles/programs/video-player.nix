{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mkchromecast
    vlc
  ];
}
