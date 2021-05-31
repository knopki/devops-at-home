{ lib, ... }:
{
  programs.direnv = {
    enable = lib.mkDefault true;
    enableNixDirenvIntegration = true;
  };
}
