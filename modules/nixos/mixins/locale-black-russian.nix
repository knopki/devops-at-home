{ lib, ... }:
{
  console.font = lib.mkDefault "LatArCyrHeb-16";

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    supportedLocales = [
      "en_DK.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_TIME = "en_DK.UTF-8";
    };
  };

  services.xserver.xkb.layout = "us,ru";
}
