{ config, lib, pkgs, ... }@args:
with lib;
let
  cfg = config.knopki.users.root;
  sshKeys = import ../secrets/ssh_keys.nix;
in
{
  knopki.users.root = { };

  users.users."${cfg.username}" = mkIf cfg.enable {
    openssh.authorizedKeys.keys = [ sshKeys.sk ];
    passwordFile = "/var/secrets/root_password";
  };
}
