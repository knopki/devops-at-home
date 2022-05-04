{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    libsForQt5.kdenlive
    obs-studio
  ];
}
