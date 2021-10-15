{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    anki
    anytype
    aspellDicts.en
    aspellDicts.ru
    birdtray
    gnome3.simple-scan
    libreoffice-fresh
    marvin
    speedcrunch
    thunderbird
  ];
}
