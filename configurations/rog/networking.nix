{
  networking.hostName = "rog";

  services.openssh.enable = true;

  systemd.network = {
    networks = {
      "40-wlp5s0".enable = false;
    };
  };
}
