{ config, lib, pkgs, ... }:
with lib;
let
  inherit (builtins) map typeOf;
  cfg = config.programs.kde;
  jsonFormat = pkgs.formats.json { };

  # formats strings, nulls, numbers, booleans and 1-dimension lists as strings
  formatKConfigValue = v:
    let
      formatValue = generators.mkValueStringDefault { };
    in
    if v == null then ""
    else if isList v then concatMapStringsSep "," formatValue v
    else formatValue v;

  # converts { a.b.c = 5; } to [{ groups = ["a" "b"]; key = "c"; value = 5; }]
  flattenKdeAttrs =
    let
      recurse = path: value:
        if isAttrs value then
          lib.mapAttrsToList (n: v: recurse ([ n ] ++ path) v) value
        else if length path > 1 then {
          groups = reverseList (tail path);
          key = head path;
          value = value;
        } else
          {
            groups = [ ];
            key = head path;
            value = value;
          };
      optsToLists = attrs: flatten (recurse [ ] attrs);
    in
    attrs: optsToLists (attrs);


  # format filename: { groups = ["a" "b"]; key = "c"; value = 5; }
  # as kwriteconfig5 command
  formatCmd = filename: { groups, key, value }:
    let
      absFileName = "${config.xdg.configHome}/${filename}";
    in
    concatStringsSep " " (filter (v: v != "") [
      "$DRY_RUN_CMD"
      "${pkgs.libsForQt5.kconfig}/bin/kwriteconfig5"
      "--file ${escapeShellArg absFileName}"
      (concatMapStringsSep " " (v: "--group ${escapeShellArg v}") groups)
      "--key ${escapeShellArg key}"
      (optionalString (typeOf value == "bool") "--type bool")
      (optionalString (typeOf value == "null") "--delete")
      (optionalString (typeOf value != "null")
        (escapeShellArg (formatKConfigValue value)))
    ]);

  # convert { filename = { ... } } to kconfig command list
  cmdList = flatten
    (mapAttrsToList
      (filename: settings:
        map (formatCmd filename) (flattenKdeAttrs settings))
      cfg.settings);
in
{
  options.programs.kde = {
    enable = mkEnableOption "Enable KDE configuration";

    settings = mkOption {
      default = { };
      example = literalExample ''{ kwinrc = { General.Foo = "bar"; }; }'';
      description = "KDE settings";
      type = with types; attrsOf jsonFormat.type;
    };

  };

  config = mkIf cfg.enable {
    home.activation.kdeSettings =
      hm.dag.entryAfter [ "writeBoundary" ] (concatStringsSep "\n" cmdList);
  };
}
