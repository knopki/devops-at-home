{
  config,
  pkgs,
  lib,
  ...
}:
{
  knopki = {
    git = {
      enable = true;
      withGitHooks = true;
      gitleaks.enable = true;
    };
    json = {
      enable = true;
      biome.enable = true;
      jq.enable = true;
      fx.enable = true;
    };
    markdown = {
      enable = true;
      format.enable = true;
      glow.enable = true;
      lychee.enable = true;
      marksman.enable = true;
      markdownlint.enable = true;
    };
    menu = {
      enable = true;
      commands = [
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
      nix-update.enable = true;
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
      format.enable = true;
      lsp.enable = true;
      yamllint.enable = true;
    };
  };
  git-hooks = {
    enable = true;
    excludes = [ "secrets/.*" ];
    hooks = {
      no-commit-to-branch.enable = false;
      lychee = {
        files = "\.md$";
        # settings.flags = ''
        #   --exclude "cache\.garnix\.io"
        # '';
      };
    };
  };
  treefmt.enable = true;

  scripts = {
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
