{ config, lib, pkgs, self, username ? "root", usr, ... }:
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

  home-manager.users = usr.utils.mkHM { inherit username config; } {
    meta.tags = getAttrs [ "isWorkstation" ] config.meta.tags;
    knopki = {
      curl.enable = true;
      env.default = true;
      fish.enable = true;
      git.enable = true;
      htop.enable = true;
      readline.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      wget.enable = true;
    };
  };
}
