{ config, lib, ... }:
{
  programs.brave = {
    enable = lib.mkDefault true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
    ];
  };
}
