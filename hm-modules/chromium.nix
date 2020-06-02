{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.chromium.enable = mkEnableOption "chromium configuration";

  config = mkIf config.knopki.chromium.enable {
    programs.chromium = {
      enable = true;
      extensions = [
        # "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      ];
    };
  };
}
