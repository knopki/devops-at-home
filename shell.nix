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
          niv = if (hasPrefix "0.2." super.haskellPackages.niv.version) then super.haskellPackages.niv else if (hasAttrByPath [ "unstable" "haskellPackages" "niv" ] pkgs) then super.unstable.haskellPackages.niv else (import sources.niv {}).niv;
          # until 20.03 try to use unstable or upstream version
          nixpkgs-fmt = if (hasPrefix "0.6." super.nixpkgs-fmt.version) then super.nixfmt-pkgs else if (hasAttrByPath [ "unstable" "nixpkgs-fmt" ] pkgs) then super.unstable.nixpkgs-fmt else (import sources.nixpkgs-fmt {});
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
