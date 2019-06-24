{ config, pkgs, lib, ... }:

with lib;

{
  options.local.hardware.sound.enable = mkEnableOption "Enable Sound";

  config = mkIf config.local.hardware.sound.enable {
    hardware = {
      pulseaudio = {
        enable = true;
        package = pkgs.pulseaudioFull;
        support32Bit = mkIf config.local.roles.workstation.enable true;
      };
    };

    environment.systemPackages = with pkgs; [
      pavucontrol
    ];
  };
}
