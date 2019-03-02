{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    local.services.ssh.enable = mkEnableOption "OpenSSH Options";
  };

  config = mkIf config.local.services.ssh.enable {
    networking.firewall.allowedTCPPorts = [ 22 ];

    services.openssh = {
      enable = true;
      openFirewall = true;
      passwordAuthentication = false;
      startWhenNeeded = true;
    };
  };
}
