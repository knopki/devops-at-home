{ config, lib, pkgs, ... }:
with builtins;
let

in {
  imports = [
    ./essential.nix
  ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "vm.swappiness" = 0;
  };
  boot.tmpOnTmpfs = true;

  environment.systemPackages = with pkgs; [
    ansible
    borgbackup
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
    openvpn
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
    syncthing
    unstable.go2nix
    unstable.vgo2nix
    virtmanager
    zerotierone
  ];

  hardware = {
    enableRedistributableFirmware = true;
    opengl.enable = true;
    sane.enable = true;
  };

  home-manager.useUserPackages = true;

  networking = {
    firewall = {
      enable = true;
    };
    networkmanager = {
      enable = true;
    };
    usePredictableInterfaceNames = true;
  };

  # powerManagement.powertop.enable = true;

  programs = {
    adb.enable = true;
    browserpass.enable = true;
    chromium = {
      enable = true;
    };
    npm.enable = true;
  };

  services = {
    flatpak = {
      enable = true;
      # extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
    # thermald.enable = true;
    upower.enable = true;
  };
}
