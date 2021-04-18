{ config, lib, pkgs, ... }:
let inherit (lib) mkDefault; in
{
  console = {
    font = mkDefault "latarcyrheb-sun16";
    keyMap = mkDefault "us";
  };

  i18n = {
    defaultLocale = mkDefault "en_US.UTF-8";
    supportedLocales = mkDefault [ "en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
  };

  services.xserver.layout = "us,ru";

  time.timeZone = mkDefault "Europe/Moscow";
}
