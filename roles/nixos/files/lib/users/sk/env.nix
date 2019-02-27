{ pkgs, config, username, ...}:
let
  selfHM = config.home-manager.users."${username}";
  uid = builtins.toString config.users.users."${username}".uid;
in with builtins;
{
  home.sessionVariables = {
    BROWSER = "firefox";
    DBUS_SESSION_BUS_ADDRESS = "unix:path=${selfHM.home.sessionVariables.XDG_RUNTIME_DIR}/bus}";
    EDITOR = "vim";
    PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    PATH = "${selfHM.home.homeDirectory}/.local/bin:${selfHM.home.homeDirectory}/.local/npm/bin:\${PATH}";
    TERMINAL = "termite";
    VISUAL = "vim";
    XDG_RUNTIME_DIR = "\${XDG_RUNTIME_DIR:-/run/user/${uid}}";
  };
}
