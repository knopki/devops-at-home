{
  pkgs,
  packages,
  ...
}:
{
  commands = [
    { package = packages.nixos-option; }
    { package = packages.update-packages; }
    { package = packages.formatter; }
    { package = pkgs.home-manager; }
    { package = pkgs.nh; }
    { package = pkgs.nil; }
    { package = pkgs.nix-inspect; }
    { package = pkgs.nixVersions.latest; }
    { package = pkgs.nixd; }
    { package = pkgs.nvd; }
    { package = pkgs.age; }
    { package = pkgs.sops; }
    { package = pkgs.vulnix; }
    { package = pkgs.nixos-anywhere; }
    { package = pkgs.deadnix; }
    { package = pkgs.nixfmt-rfc-style; }
    { package = pkgs.shellcheck; }
  ];
}
