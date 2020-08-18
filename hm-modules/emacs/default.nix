{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.emacs = { enable = mkEnableOption "enable doom emacs for user"; };

  config = mkIf config.knopki.emacs.enable {
    home.file = {
      ".emacs.d/init.el".text = ''
        (load "default.el")
      '';

      # HACK: support virtualenv and nix shells
      ".pylintrc".text = ''
        [MASTER]
        init-hook='import os,sys;[sys.path.append(p) for p in os.environ.get("PYTHONPATH","").split(":")];'
      '';
    };

    home.packages = with pkgs; [
      fd
      ripgrep

      # fonts etc
      emacs-all-the-icons-fonts
      fira-code-symbols
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      source-sans-pro

      # cc
      ccls
      irony-server
      rtags

      # csharp
      dotnet-sdk
      omnisharp-roslyn

      # docker mode
      docker
      docker-compose
      docker-machine
      dockerfile-language-server-nodejs

      # editorconfig
      python37Packages.editorconfig

      # erlang
      erlang

      # flyspell
      hunspell
      hunspellDicts.en-us-large
      hunspellDicts.ru-ru

      # go
      gopls
      gocode
      gomodifytags
      gotests

      # latex
      texlab
      texlive.combined.scheme-medium

      # javascript
      nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.prettier

      # markdown
      python37Packages.grip
      mdl
      pandoc
      proselint

      # nix-mode
      nixpkgs-fmt

      # org
      gnuplot

      # php
      php
      php73Packages.php-cs-fixer

      # plantuml
      plantuml

      # python
      python37Packages.flake8
      python37Packages.pyflakes
      python37Packages.pylint
      python37Packages.pyls-black
      python37Packages.pyls-mypy
      python37Packages.python-language-server

      # rust
      cargo
      clippy
      rls
      rustc
      rustfmt

      # sh
      bashdb
      nodePackages.bash-language-server
      shellcheck

      # wakatime-mode
      wakatime

      # web
      nodePackages.js-beautify

      # yaml
      yaml-language-server
    ];

    programs.emacs = {
      enable = true;
      package = pkgs.doom-emacs;
    };
  };
}
