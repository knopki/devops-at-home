{ config, pkgs, lib, ... }:

with lib;

{
  options.local.hardware.sound.enable = mkEnableOption "Enable Sound";

  config = mkIf config.local.hardware.sound.enable {
    sound.enable = true;

    hardware = {
      pulseaudio = {
        enable = true;
        package = pkgs.pulseaudioFull;
        support32Bit = mkIf config.local.roles.workstation.enable true;
        extraConfig = mkIf (config.local.hardware.machine == "alienware-15r2") ''
          load-module module-alsa-sink device=hw:0,0 sink_properties=device.description="Analog-Output" control=PCM
          load-module module-alsa-sink device=hw:0,1 sink_properties=device.description="HDMI-Output" control=PCM
        '';
      };
    };

    environment.systemPackages = with pkgs; [
      pavucontrol
    ];
  };
}
