{ lib, self, ... }:
let
  inherit (lib)
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
