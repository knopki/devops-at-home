final: prev: let
  flakeUtils = import ../lib/flake.nix { lib = prev.lib; };
in
{
  chemacs = prev.fetchFromGitHub (flakeUtils.getNodeGithubAttrs "chemacs");
}
