{ pkgs, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  environment.systemPackages = with pkgs; [
    acpi
    lm_sensors
    wirelesstools
    pciutils
    powertop
    usbutils
  ];

  hardware.bluetooth.enable = mkDefault true;

  services = {
    logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend";
      extraConfig = ''
        InhibitDelayMaxSec=10
      '';
    };

    thermald.enable = mkDefault true;

    tlp = {
      enable = mkDefault true;
      settings = {
        TLP_ENABLE = mkDefault "1";
        CPU_BOOST_ON_AC = mkDefault "1";
        CPU_BOOST_ON_BAT = mkDefault "0";
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = mkDefault "bluetooth";
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = mkDefault "wifi";
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = mkDefault "wifi";
      };
    };

    xserver.libinput.touchpad = {
      middleEmulation = false;
      naturalScrolling = true;
      sendEventsMode = "disabled-on-external-mouse";
    };
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=6h
  '';
}
