{ config, pkgs, lib, ... }:
let
  userRoot = (import ../lib/users/root) {
    inherit config lib pkgs;
    username = "root";
  };
in with builtins; {
  home-manager.users.root = userRoot.hm;

  networking.firewall.allowedTCPPorts = [
    22 # SSH
  ];

  programs = {
    bash = {
      enableCompletion = true;
    };
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

  users.mutableUsers = false;
  users.users.root = userRoot.systemUser;
}
