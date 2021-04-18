{ config, lib, pkgs, nixosConfig, ... }:
let
  inherit (lib) mkOption mkDefault mkIf types escapeShellArg
    filterAttrs hasPrefix mapAttrs hasAttr substring literalExample;
  inherit (lib.dev.hex) fromHex toHex2;

  cfg = config.theme;

  # @author Robert Helgesson
  mkHexColorOption = component: mkOption {
    type = types.strMatching "[0-9a-fA-F]{2}";
    example = "b1";
    visible = false;
    description = "The ${component} component value as a hexadecimal string.";
  };

  # @author Robert Helgesson
  mkDecColorOption = component: mkOption {
    type = types.ints.u8;
    example = 177;
    visible = false;
    description = "The ${component} component value as a hexadecimal string.";
  };

  # @author Robert Helgesson
  colorModule = types.submodule ({ config, ... }: {
    options = {
      hex.r = mkHexColorOption "red";
      hex.g = mkHexColorOption "green";
      hex.b = mkHexColorOption "blue";
      hex.rgb = mkOption {
        type = types.strMatching "[0-9a-fA-F]{6}";
        readOnly = true;
        visible = false;
        description = "Concatenated hexadecimal string.";
      };

      dec.r = mkDecColorOption "red";
      dec.g = mkDecColorOption "green";
      dec.b = mkDecColorOption "blue";
    };

    config = {
      hex.r = mkDefault (toHex2 config.dec.r);
      hex.g = mkDefault (toHex2 config.dec.g);
      hex.b = mkDefault (toHex2 config.dec.b);
      hex.rgb = config.hex.r + config.hex.g + config.hex.b;

      dec.r = mkDefault (fromHex config.hex.r);
      dec.g = mkDefault (fromHex config.hex.g);
      dec.b = mkDefault (fromHex config.hex.b);
    };
  });

  # @author Robert Helgesson
  fromYamlFile = yamlFile:
    let
      json = pkgs.runCommandLocal "base16-theme.json"
        {
          nativeBuildInputs = [ pkgs.remarshal ];
        } ''
        remarshal --if yaml --of json \
          < ${escapeShellArg yamlFile} \
          > $out
      '';
      bases = filterAttrs (n: _: hasPrefix "base" n)
        (builtins.fromJSON (builtins.readFile json));
    in
    mapAttrs
      (_: v: {
        hex.r = substring 0 2 v;
        hex.g = substring 2 2 v;
        hex.b = substring 4 2 v;
      })
      bases;

  presetFileMap = {
    dracula = "${pkgs.base16-dracula-scheme}/dracula.yaml";
  };


  themeFile =
    if (cfg.preset != null && hasAttr cfg.preset presetFileMap) then
      presetFileMap."${cfg.preset}"
    else
      "${pkgs.base16-default-schemes}/default-dark.yaml";
in
{
  options.theme.base16 = {
    name = mkOption {
      type = types.str;
      default = if (cfg.preset != null) then cfg.preset else "default";
    };

    # @author Robert Helgesson
    kind = mkOption {
      type = types.enum [ "dark" "light" ];
      example = "dark";
      default =
        let inherit (cfg.base16.colors.base00.dec) r g b;
        in if r + g + b >= 382 then "light" else "dark";
      defaultText = literalExample ''
        "light", if sum of RGB components of base00 color ≥ 382,
        "dark", otherwise
      '';
      description = ''
        Whether theme is dark or light. The default value is determined by a
        basic heuristic, if an incorrect value is found then this option must
        be set explicitly.
      '';
    };

    # @author Robert Helgesson
    colors =
      let
        mkHexColorOption = mkOption {
          type = colorModule;
          example = {
            dec = {
              r = 177;
              g = 42;
              b = 42;
            };
          };
          description = ''
            Color value. Either a hexadecimal or decimal RGB triplet must be
            given. If a hexadecimal triplet is given then the decimal triplet is
            automatically populated, and vice versa. That is, the example could
            be equivalently written

            <programlisting language="nix">
              { hex.r = "b1"; hex.g = "2a"; hex.b = "2a"; }
            </programlisting>

            And
            <programlisting language="nix">
              "red dec: ''${dec.r}, red hex: ''${hex.r}, rgb hex: ''${hex.rgb}"
            </programlisting>
            would expand to
            <quote>red dec: 177, red hex: b1, rgb hex: b12a2a</quote>.
          '';
        };
      in
      {
        base00 = mkHexColorOption;
        base01 = mkHexColorOption;
        base02 = mkHexColorOption;
        base03 = mkHexColorOption;
        base04 = mkHexColorOption;
        base05 = mkHexColorOption;
        base06 = mkHexColorOption;
        base07 = mkHexColorOption;
        base08 = mkHexColorOption;
        base09 = mkHexColorOption;
        base0A = mkHexColorOption;
        base0B = mkHexColorOption;
        base0C = mkHexColorOption;
        base0D = mkHexColorOption;
        base0E = mkHexColorOption;
        base0F = mkHexColorOption;
      };
  };

  config = mkIf cfg.enable {
    theme.base16.colors = fromYamlFile themeFile;
  };
}
