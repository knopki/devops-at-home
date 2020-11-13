{ config, lib, pkgs, ... }@args:
with lib;
let
  cfg = config.knopki.users.nixos;
  sshKeys = import ../secrets/ssh_keys.nix;
in
{
  knopki.users.nixos = {
    username = mkDefault "nixos";
    uid = mkDefault 1000;
  };

  users.users."${cfg.username}" = mkIf cfg.enable {
    password = "nixos";
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ sshKeys.sk ];
  };
}
