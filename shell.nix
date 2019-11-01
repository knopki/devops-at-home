{ sources ? import ./nix/sources.nix }:
let
  nur-no-pkgs = import sources.nur {
    repoOverrides = {
      knopki = import sources.nur-knopki {};
      # knopki = import ../nixexprs {};
    };
  };
  pkgs = import sources.nixpkgs {
    overlays = [
      nur-no-pkgs.repos.knopki.overlays.morph
      nur-no-pkgs.repos.knopki.overlays.niv
      nur-no-pkgs.repos.knopki.overlays.nixpkgs-fmt
    ];
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    ansible-lint
    gitAndTools.pre-commit
    morph
    niv
    nix-prefetch-git
    nixpkgs-fmt
    openssh
    shellcheck
    shfmt
    stdenv
  ];
}
