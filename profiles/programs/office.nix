{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    anki
    anytype
    aspellDicts.en
    aspellDicts.ru
    gnome3.simple-scan
    isync
    libreoffice-qt
    marvin
    offlineimap
    rclone
    speedcrunch
  ];
}
