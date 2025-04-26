{
  config,
  pkgs,
  packages,
  ...
}:
{
  commands = [
    { package = config.treefmt.build.wrapper; }
    { package = config.treefmt.programs.nixfmt.package; }
    { package = packages.generate-modules; }
    { package = packages.nixos-option; }
    { package = packages.update-packages; }
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
    { package = pkgs.deploy-rs; }
  ];
}
