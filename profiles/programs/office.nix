{ pkgs, ... }:
let
  kalkerDesktopItem = pkgs.makeDesktopItem {
    name = "kalker";
    desktopName = "Kalker";
    icon = "accessories-calculator";
    exec = "${pkgs.alacritty}/bin/alacritty -t Kalker --class Kalker -e ${pkgs.kalker}/bin/kalker";
  };
in
{
  environment.systemPackages = with pkgs; [
    anki
    anytype
    aspellDicts.en
    aspellDicts.ru
    birdtray
    gnome3.simple-scan
    kalker
    kalkerDesktopItem
    libreoffice-fresh
    marvin
    thunderbird
  ];
}
