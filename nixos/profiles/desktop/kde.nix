{ config, lib, pkgs, ... }:
let
  libsForQt5 = pkgs.plasma5Packages;
  inherit (libsForQt5) kdeApplications kdeFrameworks plasma5;
in
{
  environment.etc =
    let
      appId = "org.kde.plasma.browser_integration.json";
      source = "${libsForQt5.plasma-browser-integration}/etc/chromium/native-messaging-hosts/${appId}";
    in
    {
      "brave/native-messaging-hosts/${appId}".source = source;
      "chromium/native-messaging-hosts/${appId}".source = source;
      "opt/chrome/native-messaging-hosts/${appId}".source = source;
      "opt/vivaldi/native-messaging-hosts/${appId}".source = source;
    };

  environment.systemPackages =
    with pkgs;
    with plasma5Packages;
    with plasma5;
    with kdeApplications;
    with kdeFrameworks;
    [
      krename
      qt5.qttools
    ];

  programs =
    let
      extId = "cimiefiiaegbelhefglklhhakcgmhkai";
    in
    {
      brave.extensions = [ extId ];
      chromium.extensions = [ extId ];
      partition-manager.enable = true;
    };

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
    desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;
    };
  };

  systemd.user.services = {
    plasma-early-setup.restartIfChanged = false;
    plasma-run-with-systemd.restartIfChanged = false;
  };
}
