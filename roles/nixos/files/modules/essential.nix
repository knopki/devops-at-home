{ config, pkgs, lib, ... }:
let
  userRoot = (import ../lib/users/root) {
    inherit config lib pkgs;
    username = "root";
  };
in with builtins; {
  boot.kernel.sysctl = {
    "kernel.panic_on_oops" = 1;
    "kernel.panic" = 20;
    "net.ipv4.ip_nonlocal_bind" = 1;
    "net.ipv6.ip_nonlocal_bind" = 1;
    "vm.panic_on_oom" = 1;
  };

  # Save current configuration to generation every time
  environment.etc.current-configuration.source = "/etc/nixos";

  environment.pathsToLink = [ "/share/zsh" ];

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

  services = {
    dbus.socketActivated = true;
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
