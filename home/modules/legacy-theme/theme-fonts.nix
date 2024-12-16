{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkOption;
  cfg = config.theme.fonts;

  fontModule = types.submodule ({config, ...}: {
    options = {
      family = mkOption {
        type = types.str;
        description = "Font name";
      };

      size = mkOption {
        type = types.ints.u8;
        description = "Base font size";
      };

      packages = mkOption {
        type = types.listOf types.package;
        description = "Font package";
      };
    };
  });
in {
  options.theme.fonts = {
    regular = mkOption {
      type = fontModule;
      description = "The default font.";
      default = {
        family = "Noto Sans";
        size = 10;
        packages = [pkgs.noto-fonts];
      };
    };

    document = mkOption {
      type = fontModule;
      description = "The default font used for reading documents.";
      default = {
        family = "Noto Sans";
        size = 10;
        packages = [pkgs.noto-fonts];
      };
    };

    monospace = mkOption {
      type = fontModule;
      description = "A monospaced (fixed-width) font for use in locations like terminals.";
      default = {
        family = "Hack";
        size = 10;
        packages = [pkgs.hack-font];
      };
    };
  };

  config = {
    home.packages = cfg.regular.packages ++ cfg.document.packages ++ cfg.monospace.packages;
  };
}
