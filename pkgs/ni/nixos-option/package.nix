{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  usedFlakeCompat = pkgs.fetchFromGitHub {
    owner = "edolstra";
    repo = "flake-compat";
    rev = "12c64ca55c1014cdc1b16ed5a804aa8576601ff2";
    sha256 = "sha256-hY8g6H2KFL8ownSiFeMOjwPC8P0ueXpCVEbxgda3pko=";
  };
  prefix = ''(import ${usedFlakeCompat} { src = ${self.outPath}; }).defaultNix.nixosConfigurations.\$(hostname)'';
in
pkgs.runCommandNoCC "nixos-option" { buildInputs = [ pkgs.makeWrapper ]; } ''
  makeWrapper ${pkgs.nixos-option}/bin/nixos-option $out/bin/nixos-option \
    --add-flags --config_expr \
    --add-flags "\"${prefix}.config\"" \
    --add-flags --options_expr \
    --add-flags "\"${prefix}.options\""
''
