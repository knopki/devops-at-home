{ pkgs, ... }:
{
  env.GREET = "devops-at-home";

  packages = with pkgs; [
    git
    age
    nh
    nix-inspect
    nixos-anywhere
    nixos-option
    dix
    sops
    nixVersions.latest
    nixfmt-rfc-style
  ];

  languages.nix.enable = true;

  languages.shell.enable = true;

  scripts.update-packages.exec = ''
    export PRJ_ROOT="$DEVENV_ROOT"
    nix run .#update-packages -- "$@"
  '';
}
