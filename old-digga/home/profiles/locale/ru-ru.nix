{
  lib,
  nixosConfig,
  ...
}: let
  inherit (lib) mkDefault mkBefore;
in {
  home.language = {
    monetary = mkDefault "ru_RU.UTF-8";
    time = mkDefault "ru_RU.UTF-8";
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

    ktimezonedrc.TimeZones.LocalZone = mkDefault nixosConfig.time.timeZone;

    kxkbrc = {
      Layout = {
        LayoutList = mkDefault nixosConfig.services.xserver.layout;
        Options = mkDefault "terminate:ctrl_alt_bksp,grp:win_space_toggle";
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
