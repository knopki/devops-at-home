{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    imgcat
    imv
    gwenview
  ];
}
