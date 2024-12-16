{
  config,
  inputs,
  pkgs,
  ...
}:
{
  commands = [
    { package = pkgs.nixVersions.latest; }
    { package = config.treefmt.build.wrapper; }
    { package = config.treefmt.programs.nixfmt.package; }
    {
      name = "nvfetcher";
      help = pkgs.nvfetcher.meta.description;
      command = ''
        ${pkgs.nvfetcher}/bin/nvfetcher \
          -c $PRJ_ROOT/pkgs/nvfetcher.toml \
          -o $PRJ_ROOT/pkgs/_sources $@
      '';
    }
    { package = pkgs.home-manager; }
    { package = pkgs.nix-inspect; }
    { package = pkgs.ssh-to-pgp; }
    { package = pkgs.sops; }
    { package = pkgs.nvd; }
    { package = pkgs.lazygit; }
    { package = pkgs.nh; }
    { package = pkgs.vulnix; }
  ];
}
