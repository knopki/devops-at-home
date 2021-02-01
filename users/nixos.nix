{ config, lib, pkgs, ... }@args:
with lib;
let
  cfg = config.knopki.users.nixos;
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
    openssh.authorizedKeys.keyFiles = [ ./sk/secrets/id_rsa.pub ];
  };
}
