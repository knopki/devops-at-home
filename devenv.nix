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
      fd
      sops
    ]
    ++ (with inputs.llm-agents.packages.${system}; [ opencode ]);

  knopki = {
    json.enable = true;
    nixos.enable = true;
    markdown.enable = true;
    menu.enable = true;
    yaml.enable = true;
  };
  git-hooks.hooks.no-commit-to-branch.enable = false;
  treefmt = {
    enable = true;
    config = {
      programs = {
        shellcheck.enable = true;
        shfmt.enable = true;
      };

      settings = {
        global.excludes = [
          "*.asc"
          ".sops.yaml"
          "secrets/*.yaml"
        ];
      };
    };
  };

  languages.shell.enable = true;

  scripts = {
    update-packages.exec = ''
      export PRJ_ROOT="$DEVENV_ROOT"
      nix run .#update-packages -- "$@"
    '';

    generate-facts.exec = ''
      export MYUID=$(id -u)
      export MYGID=$(id -g)
      run0 bash -c "${lib.getExe pkgs.nixos-facter} -o facter.json && chown $MYUID:$MYGID facter.json"
    '';

    list-impermanent-files.exec = ''
      run0 fd --one-file-system --base-directory / \
        --type f --hidden --exclude "{tmp,etc/passwd}"
    '';
  };
}
