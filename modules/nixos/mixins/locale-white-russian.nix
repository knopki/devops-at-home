{ lib, ... }:
{
  console.font = lib.mkDefault "LatArCyrHeb-16";

  i18n = {
    defaultLocale = lib.mkDefault "ru_RU.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
    };
  };

  services.xserver.xkb.layout = "us,ru";
}
