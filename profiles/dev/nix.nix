{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    cachix
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
