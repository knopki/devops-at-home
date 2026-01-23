# flake.parts' flakeModule
#
# Setup formatter and checks
#
{ lib, ... }:
let
  inherit (lib.strings) makeBinPath;
in
{
  perSystem =
    { pkgs, ... }:
    rec {
      packages.formatter =
        let
          pathWithDeps = makeBinPath (
            with pkgs;
            [
              deadnix
              jsonfmt
              mdformat
              nixfmt-rfc-style
              shellcheck
              shfmt
              taplo
              treefmt
              yamlfmt
            ]
          );
        in
        pkgs.writeShellScriptBin "treefmt" ''
          PATH=${pathWithDeps}:$PATH
          exec treefmt "$@"
        '';
      inherit (packages) formatter;
      checks.format = pkgs.writeShellScriptBin "treefmt-ci" ''
        exec ${formatter} --ci "$@"
      '';
    };
}
