{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  nixDoomFlake = nixosConfig.nix.registry.nix-doom-emacs.flake;
  p = import ./packages.nix {
    inherit config lib pkgs nixDoomFlake;
  };
in
{
  imports = [ nixDoomFlake.hmModule ];

  options.knopki.emacs = {
    enable = mkEnableOption "enable doom emacs for user";
    org-capture = {
      enable = mkEnableOption "enable org-capture script";
      package = mkOption {
        description = "org-capture package";
        type = with types; package;
        default = p.doom-org-capture;
      };
    };
  };

  config = mkIf config.knopki.emacs.enable {
    home.file = {
      # HACK: support virtualenv and nix shells
      ".pylintrc".text = ''
        [MASTER]
        init-hook='import os,sys;[sys.path.append(p) for p in os.environ.get("PYTHONPATH","").split(":")];'
      '';
    };

    home.packages = with pkgs; [
      # doom dependencies
      git
      (ripgrep.override { withPCRE2 = true; })
      gnutls # for TLS connectivity

      # optional dependencies
      fd # faster projectile indexing
      imagemagick # for image-dired
      imv # feh alternative
      pinentry_emacs # in-emacs gnupg prompts
      zstd # for undo-fu-session/undo-tree compression

      ## modules dependencies
      # :checkers spell
      hunspell
      hunspellDicts.en-us-large
      hunspellDicts.ru-ru

      # :checkers grammar
      languagetool

      # :tools editorconfig
      editorconfig-core-c

      # :tools lookup & :lang org +roam
      sqlite

      # :lang cc
      ccls
      irony-server
      rtags

      # :lang csharp
      dotnet-sdk
      omnisharp-roslyn

      # :tools docker
      docker
      docker-compose
      docker-machine
      nodePackages.dockerfile-language-server-nodejs

      # :lang erlang
      erlang

      # :lang go
      gopls
      gocode
      gomodifytags
      gotests

      # :lang latex & :lang org (latex previews)
      texlive.combined.scheme-medium

      # :lang javascript
      nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.prettier

      # :lang json
      nodePackages.vscode-json-languageserver-bin

      # :lang markdown
      python37Packages.grip
      mdl
      pandoc
      proselint

      # :lang nix
      nixpkgs-fmt

      # :lang org
      gnuplot
      sway-contrib.grimshot
      p.orgProtoClientDesktopItem

      # :lang php
      php
      php73Packages.php-cs-fixer

      # :plang plantuml
      plantuml

      # :lang python
      python
      nodePackages.pyright

      # :lang rust
      cargo
      clippy
      rls
      rustc
      rustfmt

      # :lang sh
      bashdb
      nodePackages.bash-language-server
      shellcheck

      # :tools wakatime-mode
      wakatime

      # :lang web
      nodePackages.js-beautify

      # lang: yaml
      nodePackages.yaml-language-server
    ] ++ optionals config.knopki.emacs.org-capture.enable [ p.doom-org-capture ];

    home.sessionVariables = {
      EDITOR = "emacs -nw";
      VISUAL = "emacsclient -a='emacs -nw' -c";
    };

    knopki = {
      emacs.org-capture.enable = true;
      zathura.enable = true;
    };

    programs.doom-emacs = {
      inherit (p) emacsPackagesOverlay;
      enable = true;
      doomPrivateDir = ./doom.d;
    };

    services.emacs = {
      enable = true;
      client.enable = true;
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = (
        listToAttrs (
          map (x: nameValuePair x "emacsclient.desktop") [
            "application/javascript"
            "application/json"
            "application/markdown"
            "application/x-php"
            "application/x-shellscript"
            "application/x-yaml"
            "application/xml"
            "text/english"
            "text/plain"
            "text/vnd.qt.linguist" # typescript
            "text/x-c"
            "text/x-c++"
            "text/x-c++hdr"
            "text/x-c++src"
            "text/x-chdr"
            "text/x-csrc"
            "text/x-java"
            "text/x-makefile"
            "text/x-moc"
            "text/x-pascal"
            "text/x-patch"
            "text/x-python"
            "text/x-tcl"
            "text/x-tex"
          ]
        )
      ) // {
        "x-scheme-handler/org-protocol" = "org-protocol.desktop";
      };
    };
  };
}
