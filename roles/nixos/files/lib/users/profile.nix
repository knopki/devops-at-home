{ ... }:
{
  home.file = {
    ".profile".text = ''
      # export environment.d
      export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
      eval $(systemctl --user show-environment | awk '{print "export " $0}')

      # create tmux temporary directory if not exist
      [ -d $TMUX_TMPDIR ] || mkdir -p $TMUX_TMPDIR

      # If running bash
      if [ -n "$BASH_VERSION" ]; then
        # include .bashrc if it exists
        if [ -f "$HOME/.bashrc" ]; then
          . "$HOME/.bashrc"
        fi
      fi
    '';
  };
}
