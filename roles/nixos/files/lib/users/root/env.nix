{ config, username, ...}:
let
  selfHM = config.home-manager.users.root;
  uid = builtins.toString config.users.users."${username}".uid;
in with builtins;
{
  home.sessionVariables = {
    DBUS_SESSION_BUS_ADDRESS = "unix:path=${selfHM.home.sessionVariables.XDG_RUNTIME_DIR}/bus}";
    EDITOR = "vim";
    VISUAL = "vim";
    XDG_RUNTIME_DIR = "\${XDG_RUNTIME_DIR:-/run/user/${uid}}";
  };
}
