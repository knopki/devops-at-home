{ config, pkgs, lib, ... }:
let
  nixpkgsUnstable = import ../overlays/nixpkgs-unstable.nix;
  homeManager = import ../overlays/home-manager.nix;
  userRoot = (import ../lib/users/root) {
    inherit config lib pkgs;
    username = "root";
  };
in with builtins; {
  imports = [
    "${homeManager}/nixos"
  ];

  boot.kernel.sysctl = {
    "kernel.panic_on_oops" = 1;
    "kernel.panic" = 20;
    "net.ipv4.ip_nonlocal_bind" = 1;
    "net.ipv6.ip_nonlocal_bind" = 1;
    "vm.panic_on_oom" = 1;
  };

  environment.pathsToLink = [ "/share/zsh" ];

  environment.systemPackages = with pkgs; [
    bat
    curl
    fd
    file
    fish
    fish-foreign-env
    fish-theme-pure
    fzf
    gnupg
    htop
    iftop
    iotop
    jq
    pinentry
    pinentry_ncurses
    pstree
    python3 # required by ansible
    ripgrep
    rsync
    sysstat
    wget
  ];

  home-manager.users.root = userRoot.hm;

  i18n = {
    consoleFont = "latarcyrheb-sun16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
  };

  networking.firewall.allowedTCPPorts = [
    22 # SSH
  ];

  nix = {
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
      tarball-ttl = ${toString (60 * 60 * 96)}
    '';
    gc = {
      automatic = true;
      dates = "3:15";
    };
    optimise = {
      automatic = true;
      dates = [ "4:15" ];
    };
    trustedUsers = [ "@wheel" ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    pkgs = import (import ../overlays/nixpkgs-stable.nix) {
      config = config.nixpkgs.config;
      overlays = config.nixpkgs.overlays;
    };
    overlays = [
      nixpkgsUnstable
      (self: super: {
        fish = super.unstable.fish;
        fish-theme-pure = pkgs.callPackage ../overlays/fish-theme-pure.nix {};
      })
    ];
  };

  programs = {
    bash = {
      enableCompletion = true;
    };
    fish.enable = true;
    tmux = {
      enable = true;
    };
  };

  time.timeZone = "Europe/Moscow";

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild switch";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
    wheelNeedsPassword = true;
  };

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      passwordAuthentication = false;
      startWhenNeeded = true;
    };
    timesyncd = {
      enable = true;
      servers = [
        "0.ru.pool.ntp.org"
        "1.ru.pool.ntp.org"
        "2.ru.pool.ntp.org"
        "3.ru.pool.ntp.org"
      ];
    };
  };

  system = {
    autoUpgrade = {
      dates = "2:15";
      enable = true;
    };
    copySystemConfiguration = true;
  };

  users.mutableUsers = false;
  users.users.root = userRoot.systemUser;
}
