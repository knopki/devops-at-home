{ config, pkgs, lib, ... }:

with lib;

{
  options = { local.roles.essential.enable = mkEnableOption "Essential Role"; };

  config = mkIf config.local.roles.essential.enable {
    knopki.profiles.essential.enable = true;

    local = {
      general = { nixpkgs.enable = true; };

      users.setupUsers = [ "root" ];
    };

    home-manager.useUserPackages = true;

    time.timeZone = "Europe/Moscow";

    system = { nixos.versionSuffix = mkDefault ""; };
  };
}
