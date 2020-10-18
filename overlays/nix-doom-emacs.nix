final: prev: let
  flakeUtils = import ../lib/flake.nix { lib = prev.lib; };
in
rec {
  doom-emacs = prev.callPackage
    (prev.fetchFromGitHub (flakeUtils.getNodeGithubAttrs "nix-doom-emacs")) {
      doomPrivateDir = ./nonexistent;
    };
}
