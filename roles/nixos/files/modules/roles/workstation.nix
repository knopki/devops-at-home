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
      gcc
      go
      gopass
      hdparm
      lm_sensors
      mosh
      neovim
      neovim-remote
      p7zip
      pass
      pass-otp
      powertop
      python27Packages.dnspython # ???
      python27Packages.pydbus # ???
      python27Packages.pytz # ???
      python27Packages.tzlocal # ???
      qt5.qtwayland
      qt5ct
      # selinux-python TODO:BROKEN
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

    powerManagement.powertop.enable = true;

    programs = {
      adb.enable = true;
      npm.enable = true;
    };

    services = {
      flatpak.enable = true;
      fwupd.enable = true;
      trezord.enable = true;
      upower.enable = true;
    };
  };
}
