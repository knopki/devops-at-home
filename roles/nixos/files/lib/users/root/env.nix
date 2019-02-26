{ config, ...}:
let
  selfHM = config.home-manager.users.root;
in with builtins;
{
  # TODO: move to separate files
  home.sessionVariables = {
    DBUS_SESSION_BUS_ADDRESS = "unix:path=${selfHM.home.sessionVariables.XDG_RUNTIME_DIR}/bus";
    EDITOR = "vim";
    VISUAL = "vim";
  };
}
