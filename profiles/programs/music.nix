{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    elisa
    picard
    spotify
  ];
}
