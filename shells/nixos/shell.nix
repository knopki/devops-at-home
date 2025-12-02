{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    age
    nh
    nix-inspect
    nixos-anywhere
    nixos-option
    dix
    shellcheck
    sops
    update-packages
    vulnix
    deadnix
    formatter
    nil
    nixVersions.latest
    nixd
    nixfmt-rfc-style
    shellcheck
  ];
}
