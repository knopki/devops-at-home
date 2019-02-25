{ config, username, ... }:
let
  uid = builtins.toString config.users.users."${username}".uid;
in {
  home.file = {
    ".profile".text = ''
      # fix systemctl from sudo
      export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/${uid}}"
      export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
    '';
  };
}
