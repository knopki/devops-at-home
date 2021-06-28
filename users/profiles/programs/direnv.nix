{ lib, ... }:
{
  programs.direnv = {
    enable = lib.mkDefault true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };
}
