{ config, lib, pkgs, ... }:
let
  inherit (lib) genAttrs;
  defaultSopsFile = {
    sopsFile = ./secrets/secrets.yaml;
  };
  defaultOpts = defaultSopsFile // {
    owner = config.users.users.sk.name;
  };

  sysSecs = {
    sk-user-password = defaultSopsFile // {
      path = "/var/secrets/sk-user-password";
    };
  };
  usrSecs = genAttrs [
    "kopia-knopki-repo-password-file"
    "kopia-repository-config"
  ]
    (_: defaultOpts);
in
{
  imports = [ ../../profiles/core/sops ];
  sops.secrets = sysSecs // usrSecs;
}
