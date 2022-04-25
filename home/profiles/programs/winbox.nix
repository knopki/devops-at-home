{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ winbox-bin ];
}
