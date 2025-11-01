{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  environment.sessionVariables = {
    # to make Clipboard Manager work
    COSMIC_DATA_CONTROL_ENABLED = 1;
    # enable Ozone Wayland support in Chromium and Electron
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
  };

  environment.systemPackages = with pkgs; [
    # Look & feel
    cosmic-ext-tweaks
    cosmic-ext-applet-caffeine
    gnome-themes-extra

    # get some DE parts from GNOME
    baobab
    resources
    gparted
    papers # alternative to cosmic reader
    cosmic-reader # not ready to be a default pdf viewer
    file-roller # archive management
    gnome-calendar
    gnome-characters
    gnome-contacts
    gnome-font-viewer
    gnome-weather
    loupe

    quick-webapps
    hardinfo2

    config.programs.gnupg.agent.pinentryPackage
  ];

  programs = {
    gnupg.agent.pinentryPackage = mkDefault pkgs.pinentry-gnome3;
    gnome-disks.enable = mkDefault true;
    firefox.preferences = {
      # disable libadwaita theming for Firefox
      "widget.gtk.libadwaita-colors.enabled" = mkDefault false;
    };
    seahorse.enable = mkDefault true;
  };

  qt = {
    enable = mkDefault true;
    platformTheme = mkDefault "gnome";
    style = mkDefault "adwaita-dark";
  };

  services = {
    udev.packages = [ pkgs.gnome-settings-daemon ];

    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic.enable = true;
    desktopManager.cosmic.xwayland.enable = true;

    blueman.enable = mkDefault true;
    gnome = {
      evolution-data-server.enable = mkDefault true;
      gnome-online-accounts.enable = mkDefault true;
      gnome-settings-daemon.enable = mkDefault true;
      localsearch.enable = mkDefault true;
    };
  };
}
