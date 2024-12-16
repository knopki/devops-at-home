{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [ ];
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
}
