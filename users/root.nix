{ config, lib, pkgs, self, ... }@args:
with lib;
let
  username = attrByPath ["username"] "root" args;
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
