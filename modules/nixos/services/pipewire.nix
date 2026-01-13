# Use pipewire instead of PulseAudio. See https://wiki.nixos.org/wiki/PipeWire
{ lib, config, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.custom.pipewire;
in
{
  options.custom.pipewire.enable = mkEnableOption "Enable pipewire profile";

  config = mkIf cfg.enable {
    security.rtkit.enable = mkDefault config.services.pipewire.enable;
    services.pipewire = {
      enable = mkDefault true;
      alsa.enable = mkDefault true;
      # alsa.support32Bit = true;
      pulse.enable = mkDefault true;
      # If you want to use JACK applications, uncomment the following
      #jack.enable = true;
    };
  };
}
