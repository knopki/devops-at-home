{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [ nextcloud-client ];
}
