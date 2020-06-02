final: prev: let
  flakeUtils = import ../lib/flake.nix { lib = prev.lib; };
  nixpkgs = import (
    prev.fetchFromGitHub
      (flakeUtils.getNodeGithubAttrs "nixpkgs-unstable")
  ) { inherit (prev) config system; };
in
{
  clippy = nixpkgs.clippy;
  dockerfile-language-server-nodejs = nixpkgs.nodePackages.dockerfile-language-server-nodejs;
  gopls = nixpkgs.gopls;
  hunspellDicts = nixpkgs.hunspellDicts;
  nerdfonts = nixpkgs.nerdfonts;
  yaml-language-server = nixpkgs.nodePackages.yaml-language-server;
}
