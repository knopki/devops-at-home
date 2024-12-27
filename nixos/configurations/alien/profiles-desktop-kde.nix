{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.etc =
    let
      appId = "org.kde.plasma.browser_integration.json";
      source = "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/${appId}";
    in
    {
      "brave/native-messaging-hosts/${appId}".source = source;
      "chromium/native-messaging-hosts/${appId}".source = source;
      "opt/chrome/native-messaging-hosts/${appId}".source = source;
      "opt/vivaldi/native-messaging-hosts/${appId}".source = source;
    };

  environment.systemPackages = with pkgs; [ krename ];
  environment.plasma6.excludePackages = with pkgs.kdePackages; [ kate ];

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

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  services.displayManager.defaultSession = "plasmax11";
}
