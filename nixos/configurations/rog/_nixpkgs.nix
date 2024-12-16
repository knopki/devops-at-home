{
  config,
  lib,
  pkgs,
  self',
  packages,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib) getName;
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: elem (getName pkg) [ "libsciter" ];
  # nixpkgs.overlays = [ self'.overlays.default ];
  environment.systemPackages = [ packages."test-overlay" ];
}
