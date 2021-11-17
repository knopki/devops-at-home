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
  };
}
