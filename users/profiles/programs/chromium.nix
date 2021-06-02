{ lib, pkgs, ... }:
{
  programs.chromium = {
    enable = lib.mkDefault true;
    package = lib.mkDefault pkgs.ungoogled-chromium;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
    ];
  };
}
