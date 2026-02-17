# flake.parts' flakeModule
#
# Setup formatter and checks
#
_: {
  perSystem =
    { pkgs, ... }:
    {
      # Just use treefmt provided by devenv
      formatter = pkgs.writeShellScriptBin "treefmt" ''
        exec treefmt "$@"
      '';
      checks.format = pkgs.writeShellScriptBin "treefmt-ci" ''
        exec treefmt --ci "$@"
      '';
    };
}
