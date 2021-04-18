{
  programs.ssh = {
    enable = true;
    compression = true;
    controlMaster = "auto";
    controlPersist = "2h";
    extraConfig = ''
      AddKeysToAgent yes
    '';
    matchBlocks = {
      "localhost" = {
        compression = false;
        extraOptions = {
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
}
