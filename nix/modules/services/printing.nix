{ config, lib, pkgs, ... }:

with lib; {
  options.local.services.printing.enable = mkEnableOption "Enable Printing";

  config = mkIf config.local.services.printing.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [ brlaser cups-kyocera gutenprint ];
    };

    # Allow to discover wireless printers
    services.avahi = {
      enable = true;
      nssmdns = true;
    };
  };
}
