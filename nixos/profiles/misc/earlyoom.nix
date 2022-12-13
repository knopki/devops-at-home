{ lib, pkgs, config, ... }:
let
  inherit (lib) mkDefault mkIf;
in
{
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 10;
    freeSwapThreshold = 10;
    freeMemKillThreshold = 5;
    freeSwapKillThreshold = 5;
  };

  services.systembus-notify.enable = mkIf (config.services.earlyoom.enableNotifications) (mkDefault true);
}
