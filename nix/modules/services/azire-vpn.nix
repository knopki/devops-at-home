{ config, pkgs, lib, ... }:

with lib; {
  options = {
    local.services.azire-vpn = {
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
        default = "193.180.164.58:51820"; # se1.wg.azirevpn.net
        type = with types; nullOr str;
      };
      publicKey = mkOption { type = types.str; };
    };
  };

  config = mkIf config.local.services.azire-vpn.enabled {
    networking = {
      firewall.checkReversePath = mkDefault "loose";
      wireguard.interfaces."${config.local.services.azire-vpn.ifName}" = {
        ips = config.local.services.azire-vpn.ips;
        privateKeyFile = config.local.services.azire-vpn.privateKeyFile;
        allowedIPsAsRoutes = false;
        postSetup = ''
          ip link set mtu 1420 dev ${config.local.services.azire-vpn.ifName}
          wg set ${config.local.services.azire-vpn.ifName} fwmark 0xca6c
          ip -4 route add default dev ${config.local.services.azire-vpn.ifName} table 51820
          ip -4 rule add not fwmark 0xca6c table 51820
          ip -4 rule add table main suppress_prefixlength 0
          ip -6 route add default dev ${config.local.services.azire-vpn.ifName} table 51820
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
            endpoint = config.local.services.azire-vpn.endpoint;
            publicKey = config.local.services.azire-vpn.publicKey;
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
