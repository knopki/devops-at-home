{ config, lib, ... }:

with lib;
{
  options.local.virtualisation.docker.enable = mkEnableOption "Enable Docker";

  config = mkIf config.local.virtualisation.docker.enable {
    virtualisation.docker = {
      autoPrune.dates = "weekly";
      autoPrune.enable = true;
      enable = true;
      enableOnBoot = true;
      liveRestore = true;
    };
  };
}
