{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    anki
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
