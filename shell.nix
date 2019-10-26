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
        self: super: with super.lib; {
          # until 20.03 try to use unstable or upstream version
          niv = if (hasAttrByPath [ "unstable" "niv" ] super) then super.unstable.niv else (import sources.niv {}).niv;
          # until 20.03 try to use unstable or upstream version
          nixpkgs-fmt = if (hasAttrByPath [ "unstable" "nixpkgs-fmt" ] super) then super.unstable.nixpkgs-fmt else (import sources.nixpkgs-fmt {});
          morph = super.callPackage "${sources.morph}/nix-packaging" {};
        }
      )
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
