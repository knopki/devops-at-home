{ config, lib, pkgs, self, username ? "root", ... }:
let
  inherit (lib) getAttrs;
  sshKeys = import ../secrets/ssh_keys.nix;
in
{
  users.users."${username}" = {
    openssh.authorizedKeys.keys = [ sshKeys.sk ];
    passwordFile = "/var/secrets/root_password";
    shell = pkgs.fish;
  };

  home-manager.users."${username}" = {
    imports = [ ../hm-modules/core.nix ];
  };
}
