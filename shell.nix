{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs {
    overlays = [
      (
        self: super: {
          unstable = import sources.nixpkgs-unstable {
            config.allowUnfree = true;
          };
        }
      )
      (
        self: super: {
          niv = super.unstable.niv;
          nixpkgs-fmt = super.unstable.nixpkgs-fmt;
          morph = super.callPackage "${sources.morph}/nix-packaging" {};
        }
      )
    ];
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    morph
    niv
    nix-prefetch-git
    nixpkgs-fmt
    nodejs
    openssh
    shellcheck
    shfmt
    stdenv
    yarn
  ];
}
