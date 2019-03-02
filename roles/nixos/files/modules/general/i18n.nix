{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.general.i18n.enable = mkEnableOption "i18n Options";
  };

  config = mkIf config.local.general.i18n.enable {
    i18n = {
      consoleFont = "latarcyrheb-sun16";
      consoleKeyMap = "us";
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [ "en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
    };
  };
}
