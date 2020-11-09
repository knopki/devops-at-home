{ config, lib, pkgs, ... }@args:
with lib;
let
  username = attrByPath ["username"] "nixos" args;
  sshKeys = import ../secrets/ssh_keys.nix;
in
{
  users.users."${username}" = {
    uid = 1000;
    password = "nixos";
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [ sshKeys.sk ];
  };
}
