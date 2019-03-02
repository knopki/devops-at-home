{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.roles.workstation.enable = mkEnableOption "Workstation Role";
  };

  config = mkIf config.local.roles.workstation.enable {
    # "inherit" from `essential` role
    local.roles.essential.enable = true;

    local.apps.zsh.enable = true;
  };
}
