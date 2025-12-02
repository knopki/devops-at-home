{ pkgs, ... }:
{
  commands = [
    { package = pkgs.age; }
    { package = pkgs.nh; }
    { package = pkgs.nix-inspect; }
    { package = pkgs.nixos-anywhere; }
    { package = pkgs.nixos-option; }
    { package = pkgs.dix; }
    { package = pkgs.shellcheck; }
    { package = pkgs.sops; }
    { package = pkgs.update-packages; }
    { package = pkgs.vulnix; }
  ];

  devshell.packages = with pkgs; [
    age
    deadnix
    formatter
    nil
    nixVersions.latest
    nixd
    nixfmt-rfc-style
    shellcheck
  ];
}
