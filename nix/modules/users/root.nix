{ config, lib, pkgs, ... }:
with lib; {
  config = mkIf (elem "root" config.local.users.setupUsers) {
    local.users.users.root = {
      passwordFile = "/etc/nixos/secrets/root_password";
      home-config = {
        local.fish.enable = true;
        xdg.userDirs.enable = false;
      };
      openssh.authorizedKeys.keyFiles = mkDefault [ ./sk_id_rsa.pub ];
      setupUser = true;
      shell = pkgs.fish;
    };
  };
}
