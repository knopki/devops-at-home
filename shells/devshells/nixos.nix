{
  config,
  inputs,
  pkgs,
  packages,
  ...
}:
{
  commands = [
    { package = pkgs.nixVersions.latest; }
    { package = config.treefmt.build.wrapper; }
    { package = config.treefmt.programs.nixfmt.package; }
    { package = pkgs.home-manager; }
    { package = pkgs.nix-inspect; }
    { package = pkgs.ssh-to-pgp; }
    { package = pkgs.sops; }
    { package = pkgs.nvd; }
    { package = pkgs.nh; }
    { package = pkgs.vulnix; }
    { package = packages.nixos-option; }
    { package = packages.update-packages; }
  ];
}
