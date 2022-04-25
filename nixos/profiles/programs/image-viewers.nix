{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    aliza
    imgcat
    imv
  ];
}
