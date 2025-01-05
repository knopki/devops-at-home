{
  runCommand,
  makeWrapper,
  nixos-option,
  ...
}:
let
  lock = builtins.fromJSON (builtins.readFile ../../../flake.lock);
  flake-compat = fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  };
  self = import flake-compat {
    src = ../../..;
  };
  prefix = ''(import ${self.defaultNix.inputs.flake-compat.outPath} { src = ${self.defaultNix.outPath}; }).defaultNix.nixosConfigurations.\$(hostname)'';
in
runCommand "nixos-option" { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${nixos-option}/bin/nixos-option $out/bin/nixos-option \
    --add-flags --config_expr \
    --add-flags "\"${prefix}.config\"" \
    --add-flags --options_expr \
    --add-flags "\"${prefix}.options\""
''
