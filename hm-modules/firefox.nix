{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.firefox = {
    enable = mkEnableOption "firefox configuration";
    mime = mkEnableOption "associate firefox with file types and schemas";
  };

  config = mkIf config.knopki.firefox.enable {
    programs.firefox = {
      enable = true;

      profiles = {
        default = {
          id = 0;
          name = "default";
          isDefault = true;
          settings = {
            "browser.safebrowsing.allowOverride" = false;
            "browser.safebrowsing.blockedURIs.enabled" = false;
            "browser.safebrowsing.downloads.enabled" = false;
            "browser.safebrowsing.downloads.remote.block_dangerous_host" =
              false;
            "browser.safebrowsing.downloads.remote.block_dangerous" = false;
            "browser.safebrowsing.downloads.remote.block_potentially_unwanted" =
              false;
            "browser.safebrowsing.downloads.remote.block_uncommon" = false;
            "browser.safebrowsing.downloads.remote.enabled" = false;
            "browser.safebrowsing.malware.enabled" = false;
            "browser.safebrowsing.phishing.enabled" = false;
            "browser.search.countryCode" = "RU";
            "browser.search.region" = "RU";
            "browser.search.suggest.enabled" = true;
            "browser.startup.page" = 3;
            "media.peerconnection.enabled" = false;
            "network.security.esni.enabled" = true;
            "network.trr.mode" = 2; # prefer DNS-over-HTTPS
            "privacy.resistFingerprinting" = true;
            "privacy.trackingprotection.cryptomining.enabled" = true;
            "privacy.trackingprotection.fingerprinting.enabled" = true;
            "extensions.pocket.enabled" = false;
          };
        };
      };
    };

    xdg.mimeApps = mkIf config.knopki.firefox.mime {
      enable = true;
      defaultApplications = listToAttrs (
        map (x: nameValuePair x "firefox.desktop") [
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/x-extension-xht"
          "application/x-extension-xhtml"
          "application/xhtml+xml"
          "application/xml"
          "text/html"
          "x-scheme-handler/ftp"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ]
      );
    };
  };
}
