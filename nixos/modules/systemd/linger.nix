{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.systemd.linger;
in
{
  options.systemd.linger = {
    enable = mkEnableOption "Enable linger activation script";
    usernames = mkOption {
      description = "List of usernames enabled to linger";
      type = with types; listOf str;
      default = [ ];
    };
  };

  config.system.activationScripts.update-lingering =
    let
      inherit (lib) filterAttrs subtractLists catAttrs attrValues concatStringsSep stringAfter;
      lingerDirPath = "/var/lib/systemd/linger";
      enableActions = map (x: "touch ${lingerDirPath}/${x}") cfg.usernames;
      normalUsers = filterAttrs (_: v: v.isNormalUser) config.users.users;
      disabledUsernames = subtractLists cfg.usernames
        (catAttrs "name" (attrValues normalUsers));
      disableActions = map (x: "rm -f ${lingerDirPath}/${x}") disabledUsernames;
      updateLingering = ''
        mkdir -p ${lingerDirPath}
        ${concatStringsSep "\n" enableActions}
        ${concatStringsSep "\n" disableActions}
      '';
    in
    mkIf cfg.enable (stringAfter [ "users" ] updateLingering);
}
