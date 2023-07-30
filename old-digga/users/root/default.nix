{ config, lib, ... }:
let inherit (lib) optionals; in
{
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [ ../sk/secrets/id_rsa.pub ];
  };

  home-manager.users.root = { suites, ... }: {
    imports = suites.base
      ++ optionals config.meta.suites.workstation suites.workstation;
  };
}
