{
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkDefault;
in {
  imports = with inputs.nixos-hardware.nixosModules; [
    common-pc-laptop
  ];
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
