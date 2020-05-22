{ sources ? import ./nix/sources.nix }:
let
  nur-no-pkgs = import sources.nur {
    repoOverrides = {
      knopki = import sources.nur-knopki {};
      # knopki = import ../nixexprs {};
    };
  };
  pkgs = import sources.nixpkgs {};
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
    nixFlakes
    nixpkgs-fmt
    openssh
    shellcheck
    shfmt
    stdenv
  ];

  NIX_CONF_DIR = let
    current = pkgs.lib.optionalString (builtins.pathExists /etc/nix/nix.conf)
      (builtins.readFile /etc/nix/nix.conf);

    nixConf = pkgs.writeTextDir "opt/nix.conf" ''
      ${current}
      experimental-features = nix-command flakes ca-references
    '';
  in
    "${nixConf}/opt";
}
