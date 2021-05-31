{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mpv-with-scripts
  ];
}
