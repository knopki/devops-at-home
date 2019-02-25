{ ... }:
{
  home.file = {
    ".profile".text = ''
      # fix systemctl from sudo
      export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
    '';
  };
}
