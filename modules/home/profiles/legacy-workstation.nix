{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib)
    mkBefore
    mkDefault
    ;
in
{
  imports = with self.modules.homeManager; [ profiles-legacy-graphical ];

  home.language = {
    monetary = mkDefault "ru_RU.UTF-8";
    time = mkDefault "ru_RU.UTF-8";
  };

  programs = {
    firefox.profiles.default.settings = {
      "browser.search.countryCode" = mkDefault "RU";
      "browser.search.region" = mkDefault "RU";
      "intl.locale.requested" = mkDefault "ru,en-US";
    };

    git.delta.enable = mkDefault true;

    man.generateCaches = false;
  };

  qt.kde.settings = {
    kdeglobals = {
      Locale = {
        Country = mkDefault "ru";
        TimeFormat = mkDefault "%H:%M:%S";
        WeekStartDay = mkDefault 1;
      };
    };

    plasma-localerc = {
      Formats = {
        LANG = mkDefault "ru_RU.UTF-8";
        LC_NUMERIC = mkDefault "en_US.UTF-8";
        useDetailed = mkDefault true;
      };
      Translations.LANGUAGE = mkDefault "ru:en_US";
    };
  };
}
