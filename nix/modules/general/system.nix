{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.general.system = {
      enable = mkEnableOption "System Options";
      latestKernel = mkEnableOption "Use latest kernel package";
      makeLinuxFastAgain = mkEnableOption
        "Use kernel params from https://make-linux-fast-again.com/";
    };
  };

  config = mkIf config.local.general.system.enable {
    boot = {
      kernelPackages =
        mkIf config.local.general.system.latestKernel pkgs.linuxPackages_latest;
      kernelParams = mkIf config.local.general.system.makeLinuxFastAgain [
        "noibrs"
        "noibpb"
        "nopti"
        "nospectre_v2"
        "nospectre_v1"
        "l1tf=off"
        "nospec_store_bypass_disable"
        "no_stf_barrier"
        "mds=off"
        "mitigations=off"
      ];
    };

    # Save current configuration to generation every time
    environment.etc.current-configuration.source = "/etc/nixos";

    system = {
      autoUpgrade = {
        channel = "https://nixos.org/channels/nixos-19.03";
        dates = "2:15";
        enable = true;
      };
      copySystemConfiguration = true;
      stateVersion = "19.03";
    };
  };
}
