{ config, lib, pkgs, ... }:
with lib;
let
  userOpts = { name, config, ... }: {
    options = {
      enable = mkEnableOption "Enable user.";

      username = mkOption {
        type = types.str;
        default = name;
        description = "The name of the user account.";
      };

      uid = mkOption {
        type = with types; nullOr int;
        default = null;
        description = ''
          The account UID. If the UID is null, a free UID is picked on
          activation.
        '';
      };

      gid = mkOption {
        type = with types; nullOr int;
        default = null;
        description = ''
          The group GID. Create primary group for user if GID is not null.
        '';
      };

      linger = {
        enable = mkEnableOption "Enable loginctl linger for user";
      };
    };
  };
  enabledUsers = attrValues (filterAttrs (k: v: v.enable) config.knopki.users);
in
{
  options = {
    knopki.users = mkOption {
      type = with types; attrsOf (submodule userOpts);
      default = { };
      description = "Per-user configuration.";
    };
  };

  config = {
    users.groups = mkMerge (map
      (u: {
        "${u.username}" = {
          name = u.username;
          gid = u.gid;
        };
      })
      (filter (x: x.gid != null) enabledUsers));

    users.defaultUserShell = pkgs.fish;

    users.users = mkMerge (map
      (u: {
        "${u.username}" = {
          uid = mkIf (u.uid != null) u.uid;
          group = mkIf (u.gid != null) u.username;
        };
      })
      enabledUsers);

    home-manager.users = mkMerge (map
      (u: {
        "${u.username}" = {
          imports = [ ../hm-modules/core.nix ];
        };
      })
      enabledUsers);

    system.activationScripts.update-lingering =
      let
        lingerDirPath = "/var/lib/systemd/linger";
        getLingerUsernames = enable: map (u: u.username)
          (filter (u: u.linger.enable == enable)
            enabledUsers);
        enableActions = map (x: "touch ${lingerDirPath}/${x}") (getLingerUsernames true);
        disableActions = map (x: "rm -f ${lingerDirPath}/${x}") (getLingerUsernames false);
        updateLingering = ''
          mkdir -p ${lingerDirPath}
          ${concatStringsSep "\n" enableActions}
          ${concatStringsSep "\n" disableActions}
        '';
      in
      stringAfter [ "users" ] updateLingering;
  };
}
