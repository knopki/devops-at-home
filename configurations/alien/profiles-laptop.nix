{ inputs, ... }:
{
  imports = with inputs.nixos-hardware.nixosModules; [
    common-pc-laptop
  ];

  services = {
    logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend";
      extraConfig = ''
        InhibitDelayMaxSec=10
      '';
    };

    libinput.touchpad = {
      middleEmulation = false;
      naturalScrolling = true;
      sendEventsMode = "disabled-on-external-mouse";
    };
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=6h
  '';
}
