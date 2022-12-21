{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    darktable
    digikam
    gimp
    inkscape
  ];
}
