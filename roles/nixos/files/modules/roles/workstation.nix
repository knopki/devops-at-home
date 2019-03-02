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
        xserver.enable = true;
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
      "vm.swappiness" = 0;
    };
    boot.tmpOnTmpfs = true;

    environment.systemPackages = with pkgs; [
      ansible
      docker-machine-kvm2
      gcc
      gitAndTools.gitFull
      go
      gopass
      hdparm
      lm_sensors
      minikube
      mosh
      neovim
      neovim-remote
      nix-du
      nix-prefetch-git
      nodejs-10_x
      p7zip
      pass
      pass-otp
      powertop
      python27Packages.dnspython
      python27Packages.pydbus
      python27Packages.pytz
      python27Packages.tzlocal
      qt5ct
      selinux-python
      zerotierone
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
    };

    services = {
      flatpak.enable = true;
      fwupd.enable = true;
      # thermald.enable = true;
      trezord.enable = true;
      upower.enable = true;
    };
  };
}
