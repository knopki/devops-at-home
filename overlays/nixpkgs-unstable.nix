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
}
