{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (elem "root" config.local.users.setupUsers) {
    local.users.users.root = {
      hashedPassword = readFile "/etc/nixos/secrets/root_password";
      home-config = {
        local.fish.enable = true;
      };
      openssh.authorizedKeys.keyFiles = mkDefault [ "/etc/nixos/secrets/sk_id_rsa.pub" ];
      setupUser = true;
      shell = pkgs.fish;
    };
  };
}
