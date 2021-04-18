{ pkgs, lib, ... }:
let
  inherit (lib) mkBefore;
in
{
  environment = {
    gnome3.excludePackages = with pkgs.gnome3; [
      epiphany
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

    systemPackages = with pkgs; [
      gnome3.dconf-editor
      pinentry-gnome
    ];
  };

  programs = {
    dconf.enable = true;
    geary.enable = true;
  };

  services = {
    dbus.packages = with pkgs; [ gnome3.dconf ];
    gnome3 = {
      core-os-services.enable = true;
      core-shell.enable = true;
      core-utilities.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
      gnome-remote-desktop.enable = true;
      gnome-settings-daemon.enable = true;
      experimental-features.realtime-scheduling = true;
    };
    gvfs.enable = true;
    xserver.desktopManager.gnome3.enable = true;
  };

  qt5 = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
