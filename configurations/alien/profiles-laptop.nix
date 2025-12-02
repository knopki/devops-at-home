{ inputs, ... }:
{
  imports = with inputs.nixos-hardware.nixosModules; [
    common-pc-laptop
  ];

  services = {
    logind.settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend";
      InhibitDelayMaxSec = 10;
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
