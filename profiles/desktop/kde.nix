{ config, lib, pkgs, ... }:
let
  libsForQt5 = pkgs.plasma5Packages;
  inherit (libsForQt5) kdeApplications kdeFrameworks plasma5;
in
{
  environment.etc =
    let
      appId = "org.kde.plasma.browser_integration.json";
      source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/${appId}";
    in
    {
      "brave/native-messaging-hosts/${appId}".source = source;
      "chromium/native-messaging-hosts/${appId}".source = source;
      "opt/chrome/native-messaging-hosts/${appId}".source = source;
      "opt/vivaldi/native-messaging-hosts/${appId}".source = source;
    };

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
}
