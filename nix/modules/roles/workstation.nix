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
      apps = {
        gnome.enable = true;
        swaywm.enable = true;
        # xserver.enable = true;
      };

      general = {
        fonts.enable = true;
      };

      roles = {
        # "inherit" from `essential` role
        essential.enable = true;
      };

      virtualisation = {
        docker.enable = true;
        libvirtd.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      qt5ct # TODO: remove/configure
    ];

    services = {
      earlyoom = {
        notificationsCommand = "sudo -u sk DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus /etc/profiles/per-user/sk/bin/notify-send";
      };
    };
  };
}
