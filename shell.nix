{ sources ? import ./nix/sources.nix }:
let
  unstable = import sources.nixpkgs-unstable {};
  nur-no-pkgs = import sources.nur {
    repoOverrides = {
      knopki = import sources.nur-knopki {};
      # knopki = import ../nixexprs {};
    };
  };
  pkgs = import sources.nixpkgs {
    overlays = [
      (
        self: super: {
          morph = unstable.morph;
          nixpkgs-fmt = unstable.nixpkgs-fmt;
        }
      )
    ];
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    ansible-lint
    direnv
    gitAndTools.pre-commit
    haskellPackages.niv
    morph
    nix-prefetch-git
    nixpkgs-fmt
    openssh
    shellcheck
    shfmt
    stdenv
  ];
}
