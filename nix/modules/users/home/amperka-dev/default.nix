{ config, lib, pkgs, user, ... }:
with lib;
let
  defaultEnvRC = ''
    use nix
  '';
  homePath = config.home.homeDirectory;
in
{
  options.local.amperka-dev.enable = mkEnableOption "Amperka Dev helpers";

  config = mkIf config.local.amperka-dev.enable {
    home.file."dev/amperka/.envrc".text = defaultEnvRC;
    home.file."dev/amperka/shell.nix".source = ./amperka.shell.nix;

    home.file."dev/amperka-hq/.envrc".text = defaultEnvRC;
    home.file."dev/amperka-hq/shell.nix".source = ./amperka.shell.nix;

    home.file."dev/nkrkv/.envrc".text = defaultEnvRC;
    home.file."dev/nkrkv/shell.nix".source = ./amperka.shell.nix;

    home.file."dev/xodio/.envrc".text = defaultEnvRC;
    home.file."dev/xodio/shell.nix".source = ./xodio.shell.nix;
  };
}
