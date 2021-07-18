{ lib, pkgs, ... }:
{
  programs.chromium = {
    enable = lib.mkDefault true;
    package = lib.mkDefault pkgs.chromium;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
    ];
  };
}
