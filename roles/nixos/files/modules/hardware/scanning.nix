{ config, pkgs, lib, ... }:

with lib;

{
  options.local.hardware.scanning.enable = mkEnableOption "Enable Scanning";

  config = mkIf config.local.hardware.scanning.enable {
    hardware.sane = {
      enable = true;
      extraBackends = [ ];
    };
  };
}
