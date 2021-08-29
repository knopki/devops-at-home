{ config, lib, pkgs, ... }:
let
  libsForQt5 = pkgs.plasma5Packages;
  inherit (libsForQt5) kdeApplications kdeFrameworks plasma5;
in
{
  environment.systemPackages =
    with pkgs;
    with libsForQt5;
    with plasma5;
    with kdeApplications;
    with kdeFrameworks;
    [
      ark
      krename
      plasma-applet-caffeine-plus
      plasma-systemmonitor # will replace ksysguard

      # overriden
      pkgs.krohnkite
    ];

  programs.partition-manager.enable = true;

  security.pam.services.sddm.gnupg = {
    enable = true;
    noAutostart = true;
    storeOnly = true;
  };

  services.xserver = {
    displayManager = {
      lightdm.enable = false;
      sddm.enable = true;
    };
    desktopManager.plasma5.enable = true;
  };
}
