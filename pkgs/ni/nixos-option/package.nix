{
  self,
  runCommand,
  makeWrapper,
  nixos-option,
  ...
}:
let
  flakeCompat = self.inputs.flake-compat;
  prefix = ''(import ${flakeCompat.outPath} { src = ${self.outPath}; }).defaultNix.nixosConfigurations.\$(hostname)'';
in
runCommand "nixos-option" { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${nixos-option}/bin/nixos-option $out/bin/nixos-option \
    --add-flags --config_expr \
    --add-flags "\"${prefix}.config\"" \
    --add-flags --options_expr \
    --add-flags "\"${prefix}.options\""
''
