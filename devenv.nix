{ pkgs, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  env.GREET = "devops-at-home";

  packages =
    with pkgs;
    [
      age
      git
      commitizen
      nh
      nix-inspect
      nixos-anywhere
      nixos-option
      dix
      sops
      nixVersions.latest
      nixfmt-rfc-style
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
    run0 bash -c "${pkgs.nixos-facter}/bin/nixos-facter -o facter.json && chown $MYUID:$MYGID facter.json"
  '';
}
