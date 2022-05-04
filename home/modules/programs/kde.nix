{ config, lib, pkgs, ... }:
with lib;
let
  inherit (builtins) isString map typeOf;
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

  # before configuration commands
  lookAndFeelCmd =
    if (isString (cfg.settings.kdeglobals.KDE.LookAndFeelPackage or null)) then ''
      $DRY_RUN_CMD ${pkgs.libsForQt5.plasma-workspace}/bin/lookandfeeltool -a "${cfg.settings.kdeglobals.KDE.LookAndFeelPackage}" || echo "apply kde look and feel theme failed"
    '' else "";

  # reload cmds
  reloadCmd = ''
    $DRY_RUN_CMD ${pkgs.libsForQt5.qt5.qttools.bin}/bin/qdbus org.kde.KWin /KWin reconfigure || echo "KWin reconfigure failed"
    $DRY_RUN_CMD ${pkgs.libsForQt5.qt5.qttools.bin}/bin/qdbus org.kde.keyboard /modules/khotkeys reread_configuration || echo "kde keyboard reconfigure failed"
    $DRY_RUN_CMD ${pkgs.libsForQt5.qt5.qttools.bin}/bin/qdbus org.freedesktop.PowerManagement /org/kde/Solid/PowerManagement org.kde.Solid.PowerManagement.reparseConfiguration || echo "kde power management reconfiguration failed"
    $DRY_RUN_CMD ${pkgs.libsForQt5.qt5.qttools.bin}/bin/qdbus org.freedesktop.PowerManagement /org/kde/Solid/PowerManagement org.kde.Solid.PowerManagement.refreshStatus || echo "kde power management reconfiguration failed"

    # the actual values are https://github.com/KDE/plasma-workspace/blob/c97dddf20df5702eb429b37a8c10b2c2d8199d4e/kcms/kcms-common_p.h#L13
    for changeType in {0..10}; do
      $DRY_RUN_CMD ${pkgs.dbus}/bin/dbus-send /KGlobalSettings org.kde.KGlobalSettings.notifyChange int32:$changeType int32:0 || echo "KGlobalSettings.notifyChange failed"
    done
  '';

  # convert { filename = { ... } } to kconfig command list
  cmdList = [ lookAndFeelCmd ] ++ flatten
    (mapAttrsToList
      (filename: settings:
        map (formatCmd filename) (flattenKdeAttrs settings))
      cfg.settings) ++ [ reloadCmd ];
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
