{ config, username, ...}:
let
  selfHM = config.home-manager.users."${username}";
in {
  programs.ssh = {
    enable = true;
    compression = true;
    controlMaster = "auto";
    controlPersist = "2h";
    matchBlocks = {
      "localhost" = {
        extraOptions = {
          Compression = "no";
          ControlMaster = "no";
        };
      };
      "* !localhost" = {
        extraOptions = {
          ControlMaster = "auto";
          ControlPersist = "2h";
        };
      };
      "*" = {
        extraOptions = {
          TCPKeepAlive = "yes";
          ServerAliveCountMax = "10";
        };
      };
      "*.onion" = {
        extraOptions = {
          ProxyCommand = "socat - SOCKS4A:localhost:%h:%p,socksport=9050";
        };
      };
    };
    forwardAgent = true;
    serverAliveInterval = 10;
  };
}
