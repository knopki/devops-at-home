{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    qbittorrent
    youtube-dl
  ];
}
