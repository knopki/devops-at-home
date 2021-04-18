{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    blender
    darktable
    digikam
    gimp
    kdenlive
    krita
    obs-studio
  ];
}
