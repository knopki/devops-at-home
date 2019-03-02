{ pkgs, ... }:
{
  imports =
  [
    ./fish.nix
    ./gnome.nix
    ./swaywm.nix
    ./zsh.nix
  ];
}
