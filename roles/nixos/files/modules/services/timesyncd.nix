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
        servers = [
          "0.ru.pool.ntp.org"
          "1.ru.pool.ntp.org"
          "2.ru.pool.ntp.org"
          "3.ru.pool.ntp.org"
        ];
      };
    };
  };
}
