{
  lib,
  config,
  ...
}:
let
  inherit (builtins) listToAttrs;
  inherit (lib.lists) imap1;
  inherit (lib.modules) mkBefore mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.strings) concatStringsSep;
  cfg = config.custom.networking;

  planetsAndMoons = [
    "mercury"
    "venus"
    "earth"
    "moon"
    "mars"
    "phobos"
    "deimos"
    "jupiter"
    "metis"
    "adrastea"
    "amalthea"
    "thebe"
    "io"
    "europa"
    "ganymede"
    "callisto"
    "leda"
    "himalia"
    "elara"
    "ananke"
    "carme"
    "pasiphae"
    "sinope"
    "saturn"
    "pan"
    "atlas"
    "prometheus"
    "pandora"
    "epimetheus"
    "janus"
    "mimas"
    "enceladus"
    "tethys"
    "telesto"
    "calypso"
    "dione"
    "helene"
    "rhea"
    "titan"
    "hyperion"
    "iapetus"
    "phoebe"
    "uranus"
    "cordelia"
    "ophelia"
    "binaca"
    "cressida"
    "desdemona"
    "juliet"
    "protia"
    "rosalind"
    "belinda"
    "puck"
    "miranda"
    "ariel"
    "umbriel"
    "titania"
    "oberon"
    "caliban"
    "sycorax"
    "prospero"
    "setebos"
    "stephano"
    "trinculo"
    "neptune"
    "naiad"
    "thalassa"
    "despina"
    "galatea"
    "larissa"
    "proteus"
    "triton"
    "nereid"
    "pluto"
    "charon"
  ];
in
{
  options.custom.networking = {
    enable = mkEnableOption "Enable networking profile";
    devHosts = {
      enable = mkEnableOption "Add a pile of hostnames to hosts for development purposes";
      ipAddressPrefix = mkOption {
        type = lib.types.str;
        default = "127.19.84.";
        description = "IP address prefix for development hosts";
      };
      hostnameSuffix = mkOption {
        type = lib.types.str;
        default = "test";
        description = "Hostname suffix for development hosts";
      };
      hostnames = mkOption {
        type = with lib.types; listOf str;
        default = planetsAndMoons;
        description = "List of hostnames to add to hosts file";
      };
      redirectSsh = mkEnableOption "Redirect SSH :22 -> :2222";
    };
  };

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

      hosts = mkIf cfg.devHosts.enable (
        listToAttrs (
          imap1 (i: x: {
            name = "${cfg.devHosts.ipAddressPrefix}${toString i}";
            value =
              let
                domain = "${x}.${cfg.devHosts.hostnameSuffix}";
              in
              [
                domain
                "api.${domain}"
                "db.${domain}"
                "www.${domain}"
              ];
          }) cfg.devHosts.hostnames
        )
      );

      nftables = mkIf (cfg.devHosts.enable && cfg.devHosts.redirectSsh) {
        enable = mkDefault true;
        ruleset =
          let
            addresses = imap1 (i: _: "${cfg.devHosts.ipAddressPrefix}${toString i}") cfg.devHosts.hostnames;
            rules = map (addr: "tcp dport 22 ip daddr ${addr} dnat to ${addr}:2222") addresses;
          in
          mkBefore ''
            table ip nat {
              chain output {
                type nat hook output priority -100;
                ${concatStringsSep "\n" rules}
              }
            }
          '';
      };
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
