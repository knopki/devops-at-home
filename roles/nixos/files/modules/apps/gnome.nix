{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.apps.gnome.enable = mkEnableOption "Enable Gnome";
  };

  config = mkIf config.local.apps.gnome.enable {
    environment.gnome3.excludePackages = with pkgs; [
      epiphany
      gnome3.accerciser
      gnome3.evolution
      gnome3.gnome-documents
      gnome3.gnome-documents
      gnome3.gnome-logs
      gnome3.gnome-maps
      gnome3.gnome-music
      gnome3.gnome-nettool
      gnome3.gnome-photos
      gnome3.gnome-software
      gnome3.gnome-todo
      gnome3.totem
    ];

    environment.systemPackages = with pkgs; [
      gnome3.dconf-editor
      pinentry_gnome
    ];

    programs = {
      dconf.enable = true;
    };

    services = {
      accounts-daemon.enable = true;
      dbus.packages = with pkgs; [ gnome3.dconf ];
      gnome3.gnome-keyring.enable = true;
      xserver = {
        enable = true;
        desktopManager.gnome3.enable = true;
        displayManager.gdm = {
          enable = true;
          wayland = false;
        };
      };
    };
  };
}
