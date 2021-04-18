{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf attrNames length stringAfter;
  hasSecrets = length (attrNames config.sops.secrets) > 0;
in
{
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
  };

  # Dereference symlinks to /run/secrets, so users.users.<name>.passwordFile is usable
  system.activationScripts = mkIf hasSecrets {
    setup-secrets-persist = stringAfter [ "setup-secrets" ] ''
      echo persisting secrets...
      install -m 0750 -d /var/secrets
      chown root:keys /var/secrets
      find /var/secrets -type l -exec ${pkgs.bash}/bin/sh -c 'cp --remove-destination $(readlink "{}") "{}"' \;
    '';
  };
}
