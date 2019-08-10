{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.htop = mkEnableOption "enable htop for user";

  config = mkIf config.local.htop {
    programs.htop = {
      enable = true;
      sortKey = "PERCENT_MEM";
      hideThreads = true;
      hideKernelThreads = true;
      hideUserlandThreads = true;
      shadowOtherUsers = true;
      showThreadNames = true;
      showProgramPath = false;
      highlightBaseName = true;
      highlightMegabytes = true;
      cpuCountFromZero = false;
      meters = {
        left = [ "CPU" "Memory" "Swap" ];
        right = [ "Tasks" "LoadAverage" "Uptime" ];
      };
    };
  };
}
