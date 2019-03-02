{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.general.security.enable = mkEnableOption "General Security Options";
  };

  config = mkIf config.local.general.security.enable {
    # hide process information of other users when running non-root
    security.hideProcessInformation = true;

    security.sudo = {
      enable = true;
      extraRules = [
        {
          commands = [
            {
              command = "/run/current-system/sw/bin/nixos-rebuild switch";
              options = [ "NOPASSWD" ];
            }
          ];
          groups = [ "wheel" ];
        }
      ];
      wheelNeedsPassword = true;
    };
  };
}
