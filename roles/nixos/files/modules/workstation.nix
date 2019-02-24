{ config, lib, pkgs, ... }:
with builtins;
let
  nixpkgsWayland = import ../overlays/nixpkgs-wayland.nix;
  nur = import ../overlays/nur.nix;
  tmuxPlugins = import ../overlays/tmux-plugins.nix;
  vscodeExts = import ../overlays/vscode-with-extensions.nix;
in {
  imports = [
    ./earlyoom.nix
    ./essential.nix
    ./fonts.nix
    ./gnome.nix
    ./polkit.nix
    ./sway.nix
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
    neovim
    neovim-remote
    nix-du
    nix-prefetch-git
    nnn
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
    ranger
    selinux-python
    syncthing
    unstable.go2nix
    unstable.vgo2nix
    vim
    virtmanager
    zerotierone
  ];

  hardware = {
    enableRedistributableFirmware = true;
    opengl.enable = true;
    sane.enable = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };
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

  nixpkgs.overlays = [
    nixpkgsWayland
    nur
    tmuxPlugins
    vscodeExts
    (self: super: {
      sway = super.unstable.sway-beta;
      kustomize2 = pkgs.callPackage ../overlays/kustomize.nix { };
      kube-score = pkgs.callPackage ../overlays/kube-score { };
    })
  ];

  # powerManagement.powertop.enable = true;

  programs = {
    adb.enable = true;
    browserpass.enable = true;
    chromium = {
      enable = true;
    };
    npm.enable = true;
    zsh.enable = true;
  };

  services = {
    accounts-daemon.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
    };
    flatpak = {
      enable = true;
      # extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
    printing = {
      enable = true;
    };
    # thermald.enable = true;
    upower.enable = true;
    xserver = {
      desktopManager.xterm.enable = false;
      enable = true;
      layout = "us,ru";
      libinput = {
        enable = true;
        sendEventsMode = "disabled-on-external-mouse";
        middleEmulation = false;
        naturalScrolling = true;
      };
      xkbOptions = "grp:caps_toggle,grp_led:caps";
    };
  };

  sound.enable = true;

  system = {
    autoUpgrade = {
      channel = "https://nixos.org/channels/nixos-18.09";
    };
    stateVersion = "18.09";
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
    libvirtd = {
      enable = true;
    };
  };
}
