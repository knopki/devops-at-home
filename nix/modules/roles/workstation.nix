{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.roles.workstation.enable = mkEnableOption "Workstation Role";
  };

  config = mkIf config.local.roles.workstation.enable {
    knopki.nix.gcKeep = true;

    local = {
      apps = {
        gnome.enable = true;
        swaywm.enable = true;
        # xserver.enable = true;
      };

      general = {
        fonts.enable = true;
        system = {
          latestKernel = true;
          makeLinuxFastAgain = true;
        };
      };

      hardware = {
        scanning.enable = true;
      };

      roles = {
        # "inherit" from `essential` role
        essential.enable = true;
      };

      services = {
        earlyoom.enable = true;
        printing.enable = true;
      };

      virtualisation = {
        docker.enable = true;
        libvirtd.enable = true;
      };
    };

    boot = {
      kernel.sysctl = { "fs.inotify.max_user_watches" = 524288; };
      kernelParams = [ "quiet" "splash" "nohz_full=1-7" ];
      tmpOnTmpfs = true;
    };

    environment.systemPackages = with pkgs; [
      borgbackup
      fd
      fish-kubectl-completions
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
