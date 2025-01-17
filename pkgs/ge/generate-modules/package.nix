{ writeShellApplication, pkgs, ... }:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "generate-modules";
  text = readFile ./get_modules.sh;
  runtimeInputs = with pkgs; [
    findutils
    gawk
    nix
  ];
}
