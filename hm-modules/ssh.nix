{ config, lib, pkgs, ... }:
with lib; {
  options.knopki.ssh.enable = mkEnableOption "ssh default config";

  config = mkIf config.knopki.ssh.enable {
    programs.ssh = {
      enable = true;
      compression = true;
      controlMaster = "auto";
      controlPersist = "2h";
      matchBlocks = {
        "localhost" = {
          compression = false;
          extraOptions = {
            ControlMaster = "no";
          };
        };
        "* !localhost" = {
          sendEnv = [
            "TERM=xterm-256color"
          ];
          extraOptions = {
            ControlMaster = "auto";
            ControlPersist = "2h";
          };
        };
        "*" = {
          serverAliveCountMax = 10;
          extraOptions = {
            TCPKeepAlive = "yes";
          };
        };
        "*.onion" = {
          proxyCommand = "socat - SOCKS4A:localhost:%h:%p,socksport=9050";
        };
      };
      forwardAgent = true;
      serverAliveInterval = 10;
    };
  };
}
