{ lib, pkgs, ... }:
{
  services.earlyoom = {
    enable = true;
    enableDebugInfo = true;
    enableNotifications = true;
    freeSwapThreshold = 10;
  };

  systemd.user.services.systembus-notify = {
    enable = true;
    description = "Show desktop notifications for earlyoom";
    script = "${pkgs.systembus-notify}/bin/systembus-notify -q";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
  };
}
