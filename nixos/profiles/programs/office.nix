{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    anytype
    aspellDicts.en
    aspellDicts.ru
    gnome.simple-scan
    isync
    libreoffice-qt
    marvin
    offlineimap
    rclone
    speedcrunch
  ];
}
