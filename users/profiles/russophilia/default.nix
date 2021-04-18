{ lib, nixosConfig, ... }:
let
  inherit (lib) mkDefault mkBefore;
in
{
  home.language = {
    monetary = "ru_RU.UTF-8";
    time = "ru_RU.UTF-8";
  };

  programs.fish.shellInit = mkBefore ''
    export LANG=en_US.UTF-8
  '';

  programs.firefox.profiles.default.settings = {
    "browser.search.countryCode" = mkDefault "RU";
    "browser.search.region" = mkDefault "RU";
    "intl.locale.requested" = mkDefault "ru,en-US";
  };

  programs.kde.settings = {
    kdeglobals = {
      Locale = {
        Country = mkDefault "ru";
        TimeFormat = mkDefault "%H:%M:%S";
        WeekStartDay = mkDefault 1;
      };
    };

    kxkbrc = {
      Layout = {
        LayoutList = mkDefault nixosConfig.services.xserver.layout;
        Options = mkDefault "terminate:ctrl_alt_bksp,grp:win_space_toggle";
      };
    };

    plasma-localerc = {
      Formats = {
        LANG = "ru_RU.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        useDetailed = true;
      };
      Translations.LANGUAGE = "ru:en_US";
    };
  };
}
