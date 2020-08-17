{ config, lib, ... }:
with lib;
{
  options.knopki.services.azire-vpn = {
    enabled = mkEnableOption "Enable AzireVPN connection";
    ifName = mkOption {
      type = with types; nullOr str;
      default = "azire-vpn";
    };
    ips = mkOption {
      default = [];
      type = with types; listOf str;
    };
    privateKeyFile = mkOption {
      type = with types; nullOr str;
      default = "/var/secrets/azire_wg_priv";
    };
    endpoint = mkOption {
      default = "se1.wg.azirevpn.net:51820";
      type = with types; nullOr str;
    };
    publicKey = mkOption { type = types.str; };
  };

  config = mkIf config.knopki.services.azire-vpn.enabled {
    networking = {
      firewall.checkReversePath = mkDefault "loose";
      wireguard.interfaces."${config.knopki.services.azire-vpn.ifName}" = {
        ips = config.knopki.services.azire-vpn.ips;
        privateKeyFile = config.knopki.services.azire-vpn.privateKeyFile;
        allowedIPsAsRoutes = false;
        postSetup = ''
          ip link set mtu 1420 dev ${config.knopki.services.azire-vpn.ifName}
          wg set ${config.knopki.services.azire-vpn.ifName} fwmark 0xca6c
          ip -4 route add default dev ${config.knopki.services.azire-vpn.ifName} table 51820
          ip -4 rule add not fwmark 0xca6c table 51820
          ip -4 rule add table main suppress_prefixlength 0
          ip -6 route add default dev ${config.knopki.services.azire-vpn.ifName} table 51820
          ip -6 rule add not fwmark 0xca6c table 51820
          ip -6 rule add table main suppress_prefixlength 0
        '';
        postShutdown = ''
          ip -4 rule del not fwmark 0xca6c table 51820
          ip -4 rule del table main suppress_prefixlength 0
          ip -6 rule del not fwmark 0xca6c table 51820
          ip -6 rule del table main suppress_prefixlength 0
        '';
        peers = [
          {
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = config.knopki.services.azire-vpn.endpoint;
            publicKey = config.knopki.services.azire-vpn.publicKey;
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
