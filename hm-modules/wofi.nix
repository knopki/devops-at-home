{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.knopki.wofi;
  valueToString = value:
    if isBool value then (if value then "true" else "else") else toString value;
in
{
  options.knopki.wofi = {
    enable = mkEnableOption "Wofi: A Rofi and dmenu replacement";

    package = mkOption {
      default = pkgs.wofi;
      type = types.package;
    };

    extraConfig = mkOption {
      default = "";
      type = types.lines;
      description = "Additional configuration to add.";
    };

    width = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = "Window width in px or %";
      example = "50%";
    };

    height = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = "Number of lines";
      example = "40%";
    };

    term = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = ''
        Path to the terminal which will be used to run console applications
      '';
      example = "\${pkgs.gnome3.gnome_terminal}/bin/gnome-terminal";
    };

    allow_images = mkOption {
      default = null;
      type = types.nullOr types.bool;
      description = "Allows image escape sequences to be processed and rendered";
    };

    allow_markup = mkOption {
      default = null;
      type = types.nullOr types.bool;
      description = "Allows pango markup to be processed and rendered";
    };

    parse_search = mkOption {
      default = null;
      type = types.nullOr types.bool;
      description = ''
        Parses out image escapes and pango preventing them from being
        used for searching.
      '';
    };

    no_actions = mkOption {
      default = null;
      type = types.nullOr types.bool;
      description = "Disables multiple actions for modes that support it";
    };

    key_up = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = ''
        Specifies the key to use in order to move up
      '';
    };

    key_down = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = ''
        Specifies the key to use in order to move down
      '';
    };

    stylesheet = mkOption {
      default = "";
      type = types.str;
      description = "CSS Stylesheet";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."wofi/config".text = concatStringsSep "\n" [
      cfg.extraConfig
      (
        let
          opts = filterAttrs (n: v: v != null) {
            width = cfg.width;
            height = cfg.height;
            term = cfg.term;
            allow_images = cfg.allow_images;
            allow_markup = cfg.allow_markup;
            parse_search = cfg.parse_search;
            no_actions = cfg.no_actions;
            key_up = cfg.key_up;
            key_down = cfg.key_down;
          };
          strOpts = mapAttrs (n: v: valueToString v) opts;
        in
        (generators.toKeyValue { } strOpts)
      )
    ];

    xdg.configFile."wofi/style.css".text = cfg.stylesheet;
  };
}
