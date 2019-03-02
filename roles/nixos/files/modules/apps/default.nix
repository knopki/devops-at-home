{ pkgs, ... }:
{
  imports =
  [
    ./fish.nix
    ./swaywm.nix
    ./zsh.nix
  ];
}
