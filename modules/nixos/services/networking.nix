{
  lib,
  config,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption;
  cfg = config.custom.networking;
in
{
  options.custom.networking.enable = mkEnableOption "Enable networking profile";

  config = mkIf cfg.enable {
    networking = {
      # Allow PMTU / DHCP
      firewall.allowPing = mkDefault true;

      # Keep dmesg/journalctl -k output readable by NOT logging
      # each refused connection on the open internet.
      firewall.logRefusedConnections = mkDefault false;

      # Use networkd instead of the pile of shell scripts
      useNetworkd = mkDefault true;

      networkmanager.wifi.powersave = mkDefault true;

      # more privacy-friendly
      networkmanager.wifi.macAddress = mkDefault "stable-ssid";
    };

    # The notion of "online" is a broken concept
    # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
    systemd.network.wait-online.enable = false;

    systemd.services = {
      NetworkManager-wait-online.enable = false;

      # Do not take down the network for too long when upgrading,
      # This also prevents failures of services that are restarted instead of stopped.
      # It will use `systemctl restart` rather than stopping it
      # with `systemctl stop` followed by a delayed `systemctl start`.
      systemd-networkd.stopIfChanged = false;
      NetworkManager.stopIfChanged = false;
      wpa_supplicant.stopIfChanged = false;

      # Services that are only restarted might be not able to resolve when resolved is stopped before
      systemd-resolved.stopIfChanged = false;
    };
  };
}
