{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.wine = {
    enable = mkEnableOption "wine configuration";
  };
}
