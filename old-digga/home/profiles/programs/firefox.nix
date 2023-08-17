{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault;
in {
  programs.firefox = {
    enable = mkDefault true;

    package = pkgs.firefox.override {
      cfg = {
        enableBrowserpass = true;
        enablePlasmaBrowserIntegration = config.programs.kde.enable;
      };
    };

    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = mkDefault true;
        settings = {
          "browser.cache.disk.capacity" = mkDefault 128000;
          "browser.safebrowsing.allowOverride" = mkDefault false;
          "browser.safebrowsing.blockedURIs.enabled" = mkDefault false;
          "browser.safebrowsing.downloads.enabled" = mkDefault false;
          "browser.safebrowsing.downloads.remote.block_dangerous" = mkDefault false;
          "browser.safebrowsing.downloads.remote.block_dangerous_host" = mkDefault false;
          "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = mkDefault false;
          "browser.safebrowsing.downloads.remote.block_uncommon" = mkDefault false;
          "browser.safebrowsing.downloads.remote.enabled" = mkDefault false;
          "browser.safebrowsing.malware.enabled" = mkDefault false;
          "browser.safebrowsing.phishing.enabled" = mkDefault false;
          "browser.search.suggest.enabled" = mkDefault true;
          "browser.startup.page" = mkDefault 3;
          "extensions.pocket.enabled" = mkDefault false;
          "media.peerconnection.enabled" = mkDefault false;
          "network.security.esni.enabled" = mkDefault true;
          "network.trr.mode" = mkDefault 2; # prefer DNS-over-HTTPS
          "privacy.resistFingerprinting" = mkDefault true;
          "privacy.trackingprotection.cryptomining.enabled" = mkDefault true;
          "privacy.trackingprotection.fingerprinting.enabled" = mkDefault true;
        };
      };
    };
  };
}
