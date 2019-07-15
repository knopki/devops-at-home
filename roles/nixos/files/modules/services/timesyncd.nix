{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.services.timesyncd.enable = mkEnableOption "Timesyncd Options";
  };

  config = mkIf config.local.services.timesyncd.enable {
    services = {
      timesyncd = {
        enable = true;
        servers = ["time.cloudflare.com"];
      };
    };
  };
}
