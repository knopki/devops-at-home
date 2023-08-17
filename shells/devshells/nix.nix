{
  config,
  pkgs,
  ...
}: {
  commands = [
    {package = pkgs.nixUnstable;}
    {package = config.treefmt.build.wrapper;}
    {
      name = "nvfetcher";
      help = pkgs.nvfetcher.meta.description;
      command = ''
        ${pkgs.nvfetcher}/bin/nvfetcher \
          -c $PRJ_ROOT/pkgs/nvfetcher.toml \
          -o $PRJ_ROOT/pkgs/_sources
      '';
    }
  ];
}
