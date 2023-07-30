{ config, lib, pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  # delay start
  systemd.user = {
    services.${config.services.syncthing.tray.package.pname} = {
      Install.WantedBy = lib.mkForce [ ];
    };

    timers.${config.services.syncthing.tray.package.pname} = {
      Timer = {
        OnActiveSec = "10s";
        AccuracySec = "1s";
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
