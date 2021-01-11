{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  cfg = config.theme.fonts;

  fontModule = types.submodule ({ config, ... }: {
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
in
{
  options.theme.fonts = {
    regular = mkOption {
      type = fontModule;
      description = "The default font.";
      default = {
        family = "Cantarell";
        size = 11;
        packages = [ pkgs.cantarell-fonts ];
      };
    };

    document = mkOption {
      type = fontModule;
      description = "The default font used for reading documents.";
      default = {
        family = "Cantarell";
        size = 11;
        packages = [ pkgs.cantarell-fonts ];
      };
    };

    monospace = mkOption {
      type = fontModule;
      description = "A monospaced (fixed-width) font for use in locations like terminals.";
      default = {
        family = "Source Code Pro";
        size = 10;
        packages = [ pkgs.source-code-pro ];
      };
    };
  };

  config = {
    home.packages = cfg.regular.packages ++ cfg.document.packages ++ cfg.monospace.packages;
  };
}
