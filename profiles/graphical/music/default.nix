{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    picard
    spotify
  ];
}
