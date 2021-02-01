{ config, lib, pkgs, ... }:
with lib;
let
  defaultSopsFile = {
    format = "yaml";
    sopsFile = ./secrets/secrets.yaml;
  };
  defaultOpts = defaultSopsFile // {
    owner = config.knopki.users.sk.username;
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
  sops.secrets = sysSecs // usrSecs;
}
