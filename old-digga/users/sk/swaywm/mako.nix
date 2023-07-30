{ config, lib, pkgs, ... }:
let
  inherit (lib) mkAfter;
in
{
  programs.mako = {
    enable = true;
    sort = "+time";
    maxVisible = 10;
    layer = "overlay";
    borderRadius = 5;
  };

  xdg.configFile."mako/config" = {
    text = mkAfter ''
      [app-name="Spotify"]
      default-timeout=10000
    '';
    onChange = ''
      echo "Reloading mako"
      XDG_RUNTIME_DIR=/run/user/$UID $DRY_RUN_CMD systemctl --user restart mako
    '';
  };

  systemd.user.services = {
    mako = {
      Unit = {
        Description = "A lightweight Wayland notification daemon";
        Documentation = "man:mako(1)";
        PartOf = "graphical-session.target";
      };
      Service = {
        Type = "simple";
        Restart = "always";
        ExecStart = "${pkgs.mako}/bin/mako";
      };
      Install = { WantedBy = [ "sway-session.target" ]; };
    };
  };
}
