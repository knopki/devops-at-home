{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) genAttrs;
  defaultSopsFile = {
    sopsFile = ./secrets/secrets.yaml;
  };
  defaultOpts =
    defaultSopsFile
    // {
      owner = config.users.users.sk.name;
    };

  sysSecs = {
    sk-user-password =
      defaultSopsFile
      // {
        path = "/var/secrets/sk-user-password";
        neededForUsers = true;
      };
  };
  usrSecs =
    genAttrs [
      "kopia-knopki-repo-password-file"
      "kopia-repository-config"
      "nextcloud-sk-vdirsyncer-password"
      "nextcloud-sk-vdirsyncer-username"
    ]
    (_: defaultOpts);
in {
  sops.secrets = sysSecs // usrSecs;
}
