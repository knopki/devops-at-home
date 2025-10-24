{ pkgs, ... }:
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
    # DE stuff
    cosmic-ext-tweaks
    cosmic-ext-applet-caffeine
    cosmic-reader
    cosmic-store
    gnome-themes-extra
    quick-webapps

    # System stuff
    gnome-disk-utility
    gparted
  ];

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  services = {
    udev.packages = with pkgs; [ gnome-settings-daemon ];

    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic.enable = true;
    desktopManager.cosmic.xwayland.enable = true;
  };
}
