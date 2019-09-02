{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.chromium.enable = mkEnableOption "chromium configuration";

  config = mkIf config.local.chromium.enable {
    programs.chromium = {
      enable = true;
      extensions = [
        # "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      ];
    };
  };
}
