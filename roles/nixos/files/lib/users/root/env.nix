{ pkgs, config, ...}:
let
  selfHM = config.home-manager.users.root;
in with builtins;
{
  # TODO: move to separate files
  home.sessionVariables = {
    EDITOR = "vim";
    SSH_AUTH_SOCK = "\${SSH_AUTH_SOCK:-\${XDG_RUNTIME_DIR}/keyring/ssh}";
    VISUAL = "vim";
  };
}
