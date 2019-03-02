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
  };

  users.mutableUsers = false;
  users.users.root = userRoot.systemUser;
}
