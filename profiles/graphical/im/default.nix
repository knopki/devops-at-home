{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    discord
    skypeforlinux
    tdesktop
    zoom-us
  ];
}
