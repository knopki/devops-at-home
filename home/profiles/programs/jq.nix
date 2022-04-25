{ lib, ... }:
{
  programs.jq.enable = lib.mkDefault true;
}
