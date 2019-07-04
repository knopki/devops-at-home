{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.roles.workstation.enable = mkEnableOption "Workstation Role";
  };

  config = mkIf config.local.roles.workstation.enable {
    local = {
      apps = {
        gnome.enable = true;
        swaywm.enable = true;
        # xserver.enable = true;
        zsh.enable = true;
      };

      general = {
        fonts.enable = true;
      };

      hardware = {
        scanning.enable = true;
        sound.enable = true;
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

    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
    };
    boot.tmpOnTmpfs = true;

    environment.systemPackages = with pkgs; [
      borgbackup
      fd
      fish-kubectl-completions
      gcc
      go
      gopass
      hdparm
      lm_sensors
      mosh
      neovim
      neovim-remote
      ngrep
      nmap
      p7zip
      pass
      pass-otp
      powertop
      qt5.qtwayland
      qt5ct
      skypeforlinux
      wine
    ];

    hardware = {
      opengl.enable = true;
    };

    networking = {
      firewall = {
        enable = true;
      };
      networkmanager = {
        enable = true;
        dns = "dnsmasq";
      };
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
      trezord.enable = true;
      upower.enable = true;
    };
  };
}
