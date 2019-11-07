{ pkgs, ... }: {
  imports = [ ./gnome.nix ./swaywm.nix ./xserver.nix ];
}
