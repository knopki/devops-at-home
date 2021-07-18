{ config, nixosConfig, lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
  chromiumExts = [
    { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # plasma integration
  ];
in
{
  programs = {
    kde = {
      enable = mkDefault true;
      settings = {
        kdeglobals.KDE.SingleClick = mkDefault false;

        kxkbrc.Layout = {
          ResetOldOptions = mkDefault true;
          SwitchMode = mkDefault "Window";
          Use = mkDefault true;
        };
      };
    };

    brave.extensions = chromiumExts;
    chromium.extensions = chromiumExts;
    vivaldi.extensions = chromiumExts;
  };

  xdg.configFile."vivaldi/NativeMessagingHosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
