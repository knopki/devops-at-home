{ config, pkgs, lib, ... }:

with lib;

{
  options = { local.apps.xserver.enable = mkEnableOption "Enable X Server"; };

  config = mkIf config.local.apps.xserver.enable {
    services.xserver = {
      desktopManager.xterm.enable = false;
      enable = true;
      layout = "us,ru";
      libinput = {
        enable = true;
        sendEventsMode = "disabled-on-external-mouse";
        middleEmulation = false;
        naturalScrolling = true;
      };
      xkbOptions = "grp:caps_toggle,grp_led:caps";
    };
  };
}
