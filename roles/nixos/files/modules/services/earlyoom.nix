{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.services.earlyoom.enable = mkEnableOption "EarlyOOM Options";
  };

  config = mkIf config.local.services.earlyoom.enable {
    services.earlyoom = {
      enable = true;
      freeMemThreshold = 1;
      freeSwapThreshold = 80;
    };
  };
}
