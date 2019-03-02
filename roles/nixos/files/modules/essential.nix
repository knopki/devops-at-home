{ config, pkgs, lib, ... }:
let
  userRoot = (import ../lib/users/root) {
    inherit config lib pkgs;
    username = "root";
  };
in with builtins; {
  home-manager.users.root = userRoot.hm;

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
  };

  users.mutableUsers = false;
  users.users.root = userRoot.systemUser;
}
