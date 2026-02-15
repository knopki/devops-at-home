{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  packages = with inputs.llm-agents.packages.${system}; [ opencode ];

  knopki = {
    git = {
      enable = true;
      withGitHooks = true;
      difftastic.enable = true;
      gitleaks.enable = true;
      lazygit.enable = true;
    };
    json = {
      enable = true;
      jq.enable = true;
      fx.enable = true;
    };
    markdown = {
      enable = true;
      glow.enable = true;
      lychee.enable = true;
      marksman.enable = true;
      markdownlint.enable = true;
    };
    menu = {
      enable = true;
      commands = [
        {
          inherit (config.scripts.update-packages) description;
          name = "update-packages";
        }
        {
          inherit (config.scripts.generate-facts) description;
          name = "generate-facts";
        }
        {
          inherit (config.scripts.list-impermanent-files) description;
          name = "list-impermanent-files";
        }
      ];
    };
    nix = {
      enable = true;
      lsp.enable = true;
      nixfmt.enable = true;
      flake-checker.enable = true;
      deadnix.enable = true;
      statix.enable = true;
      dix.enable = true;
    };
    nixos = {
      enable = true;
      nh.enable = true;
      nix-inspect.enable = true;
      nixos-anywhere.enable = true;
      nixos-rebuild.enable = true;
      nixos-install-tools.enable = true;
      vulnix.enable = true;
    };
    secrets = {
      libsecret.enable = pkgs.stdenv.isLinux;
      sops.enable = true;
    };
    security.trivy.enable = true;
    shell = {
      enable = true;
      lsp.enable = true;
      fd.enable = true;
      ripgrep.enable = true;
      shellcheck.enable = true;
      shfmt.enable = true;
    };
    yaml = {
      enable = true;
      yamllint.enable = true;
    };
  };
  git-hooks = {
    enable = true;
    hooks = {
      no-commit-to-branch.enable = false;
      lychee.settings.flags = ''
        --exclude "cache\.garnix\.io"
      '';
    };
  };
  treefmt.enable = true;

  scripts = {
    update-packages = {
      description = "Update ./pkgs from upstream sources";
      exec = ''
        export PRJ_ROOT="$DEVENV_ROOT"
        nix run .#update-packages -- "$@"
      '';
    };

    generate-facts = {
      description = "Generate facter report for the current host";
      exec = ''
        export MYUID=$(id -u)
        export MYGID=$(id -g)
        run0 bash -c "${lib.getExe pkgs.nixos-facter} -o facter.json && run0 chown $MYUID:$MYGID facter.json"
      '';
    };

    list-impermanent-files = {
      description = "List files on the impermanent root filesystem";
      exec = ''
        run0 fd --one-file-system --base-directory / \
          --type f --hidden --exclude "{tmp,etc/passwd}"
      '';
    };
  };
}
