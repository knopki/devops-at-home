{ lib, ... }:
{
  programs.chromium = {
    enable = lib.mkDefault true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
    ];
  };
}
