{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.roles.workstation.enable = mkEnableOption "Workstation Role";
  };

  config = mkIf config.local.roles.workstation.enable {
    knopki = {
      nix.gcKeep = true;
      system.optimizeForWorkstation = true;
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

      hardware = {
        scanning.enable = true;
      };

      roles = {
        # "inherit" from `essential` role
        essential.enable = true;
      };

      services = {
        printing.enable = true;
      };

      virtualisation = {
        docker.enable = true;
        libvirtd.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      borgbackup
      fd
      gcc
      gopass
      hdparm
      keybase
      keybase-gui
      mosh
      ngrep
      nmap
      p7zip
      pass
      pass-otp
      powertop
      qt5.qtwayland
      qt5ct
    ];

    hardware = { opengl.enable = true; };

    networking = {
      firewall = {
        enable = true;
        rejectPackets = true;
      };
      networkmanager.enable = true;
      usePredictableInterfaceNames = true;
    };

    programs = {
      adb.enable = true;
      npm.enable = true;
      ssh.startAgent = true;
    };

    services = {
      earlyoom = {
        enable = true;
        notificationsCommand = "sudo -u sk DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus /etc/profiles/per-user/sk/bin/notify-send";
      };
      flatpak.enable = true;
      fwupd.enable = true;
      locate = {
        enable = true;
        localuser = null;
        locate = pkgs.mlocate;
        pruneBindMounts = true;
      };
      kbfs.enable = true;
      keybase.enable = true;
      trezord.enable = true;
    };
  };
}
