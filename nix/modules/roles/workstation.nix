{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.roles.workstation.enable = mkEnableOption "Workstation Role";
  };

  config = mkIf config.local.roles.workstation.enable {
    knopki = {
      profiles.workstation.enable = true;
    };

    local = {
      roles = {
        # "inherit" from `essential` role
        essential.enable = true;
      };
    };

    services = {
      earlyoom = {
        notificationsCommand = "sudo -u sk DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus /etc/profiles/per-user/sk/bin/notify-send";
      };
    };

    nix.package = pkgs.nixFlakes;
  };
}
