final: prev:
let
  flakeUtils = import ../lib/flake.nix { lib = prev.lib; };
  nixpkgs = import
    (
      prev.fetchFromGitHub
        (flakeUtils.getNodeGithubAttrs "nixpkgs-unstable")
    )
    { inherit (prev) config system; };
in
{
  dracula-theme = nixpkgs.dracula-theme;
  kopia = nixpkgs.kopia;
  materia-theme = nixpkgs.materia-theme;
}
