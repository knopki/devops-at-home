{ pkgs, lib, ... }:
{
  documentation.nixos.enable = true;

  environment.systemPackages = with pkgs; [
    cachix
    graphviz
    nix-du
    nix-index
    nix-prefetch-git
    nixpkgs-fmt
    manix
  ];

  nix.extraOptions = lib.mkBefore ''
    keep-derivations = true
    keep-env-derivations = true
    keep-outputs = true
  '';
}
