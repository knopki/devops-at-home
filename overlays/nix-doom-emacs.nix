final: prev: let
  flakeUtils = import ../lib/flake.nix { lib = prev.lib; };
in
rec {
  doom-emacs-pre = prev.callPackage
    (prev.fetchFromGitHub (flakeUtils.getNodeGithubAttrs "nix-doom-emacs"));
  doom-emacs = doom-emacs-pre { doomPrivateDir = ../hm-modules/emacs/doom.d; };
}
