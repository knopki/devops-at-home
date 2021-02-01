{ config, lib, pkgs, ... }@args:
with lib;
let
  cfg = config.knopki.users.root;
in
{
  knopki.users.root = { };

  users.users."${cfg.username}" = mkIf cfg.enable {
    openssh.authorizedKeys.keyFiles = [ ./sk/secrets/id_rsa.pub ];
  };
}
