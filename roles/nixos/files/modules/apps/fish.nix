{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.apps.fish.enable = mkEnableOption "Fish Shell Options";
  };

  config = mkIf config.local.apps.fish.enable {
    environment.systemPackages = with pkgs; [
      fish
      fish-foreign-env
      fish-theme-pure
    ];

    programs.fish = {
      enable = true;
    };
  };
}
