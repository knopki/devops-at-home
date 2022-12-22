{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    anytype
    aspellDicts.en
    aspellDicts.ru
    gnome.simple-scan
    isync
    marvin
    offlineimap
    rclone
    speedcrunch
  ];
}
