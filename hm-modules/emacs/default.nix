{ config, lib, pkgs, ... }:
with lib;
let
  emacsPkg = pkgs.doom-emacs.override {
    # https://github.com/vlaci/nix-doom-emacs/issues/62#issuecomment-711092166
    doomPrivateDir = builtins.path { path = ./doom.d; };
  };
  orgProtoClientDesktopItem = pkgs.writeTextDir "share/applications/org-protocol.desktop"
    (
      generators.toINI {} {
        "Desktop Entry" = {
          Type = "Application";
          Exec = "${emacsPkg}/bin/emacsclient -c %u";
          Terminal = false;
          Name = "Org Protocol";
          Icon = "emacs";
          MimeType = "x-scheme-handler/org-protocol;";
          Categories = "Utility;TextEditor;";
          StartupWMClass = "Emacs";
        };
      }
    );
in
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
      # doom dependencies
      git
      (ripgrep.override { withPCRE2 = true; })
      gnutls # for TLS connectivity

      # optional dependencies
      fd # faster projectile indexing
      imagemagick # for image-dired
      pinentry_emacs # in-emacs gnupg prompts
      zstd # for undo-fu-session/undo-tree compression

      # fonts etc
      emacs-all-the-icons-fonts
      fira-code-symbols
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      source-sans-pro

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
      dockerfile-language-server-nodejs

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
      vscode-json-language-server-bin

      # :lang markdown
      python37Packages.grip
      mdl
      pandoc
      proselint

      # :lang nix
      nixpkgs-fmt

      # :lang org
      gnuplot
      grimshot
      orgProtoClientDesktopItem

      # :lang php
      php
      php73Packages.php-cs-fixer

      # :plang plantuml
      plantuml

      # :lang python
      python
      pyright

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
      yaml-language-server
    ];

    home.sessionVariables = {
      EDITOR = "emacs -nw";
      VISUAL = "emacsclient -a='emacs -nw' -c";
    };

    programs.emacs = {
      enable = true;
      package = emacsPkg;
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
