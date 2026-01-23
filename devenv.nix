{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  packages =
    with pkgs;
    [
      age
      commitizen
      dix
      git
      fd
      nh
      nixVersions.latest
      nix-inspect
      nixfmt-rfc-style
      nixos-anywhere
      nixos-build-vms
      nixos-install-tools
      sops
    ]
    ++ (with inputs.llm-agents.packages.${system}; [ opencode ]);

  languages.nix.enable = true;

  languages.shell.enable = true;

  scripts.update-packages.exec = ''
    export PRJ_ROOT="$DEVENV_ROOT"
    nix run .#update-packages -- "$@"
  '';

  scripts.generate-facts.exec = ''
    export MYUID=$(id -u)
    export MYGID=$(id -g)
    run0 bash -c "${lib.getExe pkgs.nixos-facter} -o facter.json && chown $MYUID:$MYGID facter.json"
  '';

  scripts.list-impermanent-files.exec = ''
    run0 fd --one-file-system --base-directory / \
      --type f --hidden --exclude "{tmp,etc/passwd}"
  '';
}
