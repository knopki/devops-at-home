{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.general.security.enable = mkEnableOption "General Security Options";
  };

  config = mkIf config.local.general.security.enable {
    # hide process information of other users when running non-root
    security.hideProcessInformation = true;

    security.polkit.extraConfig = ''
      /* Allow users in wheel group to manage systemd units without authentication */
      polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              subject.isInGroup("wheel")) {
              return polkit.Result.YES;
          }
      });
    '';

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
