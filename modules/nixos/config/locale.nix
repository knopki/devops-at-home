{ config, lib, ... }:
let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkDefault mkIf mkMerge;
  cfg = config.custom.locale;
in
{
  options.custom.locale = {
    enable = mkEnableOption "Enable locale profile";
    flavor = mkOption {
      type = lib.types.enum [
        "en_US"
        "en_RU"
        "en_RU_alt"
      ];
      default = "en_US";
      description = "Locale flavor";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      console.font = mkDefault "LatArCyrHeb-16";
      console.earlySetup = mkDefault true;
    }

    (mkIf (cfg.flavor == "en_US") {
      i18n.defaultLocale = mkDefault "en_US.UTF-8";
    })

    (mkIf (cfg.flavor == "en_RU") {
      i18n = {
        defaultLocale = mkDefault "en_US.UTF-8";
        extraLocaleSettings.LC_TIME = "en_DK.UTF-8";
      };
      services.xserver.xkb.layout = "us,ru";
    })

    (mkIf (cfg.flavor == "en_RU_alt") {
      i18n = {
        defaultLocale = mkDefault "ru_RU.UTF-8";
        extraLocaleSettings = {
          LC_MESSAGES = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
        };
      };
      services.xserver.xkb.layout = "us,ru";
    })
  ]);
}
