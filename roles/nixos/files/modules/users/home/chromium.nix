{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.chromium = mkEnableOption "chromium configuration";

  config = mkIf config.local.chromium {
    programs.chromium = {
      enable = true;
      extensions = [
        # "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      ];
    };
  };
}
