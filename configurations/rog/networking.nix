{
  networking.hostName = "rog";
  networking.networkmanager.wifi.powersave = true;
  networking.networkmanager.wifi.macAddress = "stable-ssid";

  services.openssh.enable = true;

  systemd.network = {
    networks = {
      "40-wlp5s0".enable = false;
    };
  };
}
