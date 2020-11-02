final: prev: let
  flakeUtils = import ../lib/flake.nix { lib = prev.lib; };
  doom-emacs-src = prev.fetchFromGitHub
    (flakeUtils.getNodeGithubAttrs "doom-emacs");
in
rec {
  doom-emacs = prev.callPackage
    (prev.fetchFromGitHub (flakeUtils.getNodeGithubAttrs "nix-doom-emacs")) {
    dependencyOverrides = {
      "doom-src" = doom-emacs-src;
    };
    # should be overriden
    doomPrivateDir = ./nonexistent;
  };
  doom-org-capture = prev.callPackage (
    { stdenv, lib, makeWrapper, pkgs, emacsPkg ? doom-emacs, ... }:
      stdenv.mkDerivation rec {
        name = "doom-org-capture";
        src = doom-emacs-src;
        nativeBuildInputs = [ makeWrapper ];
        installPhase = ''
          install -Dm0755 $src/bin/org-capture $out/bin/$name
          wrapProgram $out/bin/$name \
            --set PATH "${emacsPkg}/bin:${pkgs.coreutils}/bin"
        '';
      }
  ) {};
}
