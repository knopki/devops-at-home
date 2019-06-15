{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.apps.fish.enable = mkEnableOption "Fish Shell Options";
  };

  config = mkIf config.local.apps.fish.enable {
    programs.fish = {
      enable = true;
      vendor.completions.enable = true;
      vendor.config.enable = true;
      vendor.functions.enable = true;
    };
  };
}
