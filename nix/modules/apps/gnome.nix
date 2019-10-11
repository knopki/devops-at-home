{ config, pkgs, lib, ... }:

with lib;

{
  options = { local.apps.gnome.enable = mkEnableOption "Enable Gnome"; };

  config = mkIf config.local.apps.gnome.enable {
    environment.gnome3.excludePackages = with pkgs.gnome3; [
      epiphany
      geary
      gnome-calendar
      gnome-characters
      gnome-clocks
      gnome-contacts
      gnome-logs
      gnome-maps
      gnome-music
      gnome-photos
      gnome-screenshot
      gnome-software
      gnome-weather
      totem
      yelp
    ];

    environment.systemPackages = with pkgs; [
      gnome3.dconf-editor
      pinentry_gnome
    ];

    local.hardware.sound.enable = true;

    programs = { dconf.enable = true; };

    services = {
      dbus.packages = with pkgs; [ gnome3.dconf ];
      gnome3 = {
        core-os-services.enable = true;
        core-shell.enable = true;
        core-utilities.enable = true;
      };
      xserver = { desktopManager.gnome3.enable = true; };
    };
  };
}
