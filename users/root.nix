{ config, lib, pkgs, self, username ? "root", usr, ... }:
let
  inherit (lib) getAttrs;
  isWorkstation = config.meta.tags.isWorkstation;
  sshKeys = import ../secrets/ssh_keys.nix;
in
{
  users.users."${username}" = {
    openssh.authorizedKeys.keys = [ sshKeys.sk ];
    passwordFile = "/var/secrets/root_password";
    shell = pkgs.fish;
  };

  home-manager.users = usr.utils.mkHM { inherit username config; } {
    meta.tags = getAttrs [ "isWorkstation" ] config.meta.tags;
    knopki = {
      starship.enable = isWorkstation;
    };
  };
}
