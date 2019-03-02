{ config, pkgs, lib, ... }:
let
  userRoot = (import ../lib/users/root) {
    inherit config lib pkgs;
    username = "root";
  };
in with builtins; {
  home-manager.users.root = userRoot.hm;
  users.mutableUsers = false;
  users.users.root = userRoot.systemUser;
}
