{ pkgs, ... }:
{
  imports =
  [
    ./fish.nix
    ./gnome.nix
    ./swaywm.nix
    ./xserver.nix
    ./zsh.nix
  ];
}
