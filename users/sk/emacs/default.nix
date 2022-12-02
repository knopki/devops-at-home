{ config, lib, pkgs, nixosConfig, inputs, ... }:
let
  inherit (lib) listToAttrs nameValuePair;
  p = import ./packages.nix {
    inherit config inputs lib pkgs;
    nixDoomFlake = inputs.nix-doom-emacs;
  };
in
{
  home.packages = with pkgs; [
    # doom dependencies
    git
    (ripgrep.override { withPCRE2 = true; })
    gnutls # for TLS connectivity

    # optional dependencies
    fd # faster projectile indexing
    imagemagick # for image-dired
    pinentry-emacs # in-emacs gnupg prompts
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

    # :tools docker
    podman
    podman-compose
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
    nodePackages.markdownlint-cli
    pandoc
    proselint
    python3Packages.grip

    # :lang nix
    nixpkgs-fmt

    # :lang org
    gnuplot
    sway-contrib.grimshot
    p.doom-org-capture
    p.orgProtoClientDesktopItem

    # :lang php
    php
    php82Packages.php-cs-fixer

    # :plang plantuml
    plantuml

    # :lang python
    python
    nodePackages.pyright

    # :lang rust
    cargo
    clippy
    rustc
    rustfmt

    # :lang sh
    bashdb
    nodePackages.bash-language-server
    shellcheck

    # :lang web
    nodePackages.js-beautify

    # lang: yaml
    nodePackages.yaml-language-server
  ];

  home.sessionVariables = {
    EDITOR = "emacs -nw";
    VISUAL = "emacsclient -a='emacs -nw' -c";
  };

  programs = {
    imv.enable = true;
    zathura.enable = true;
    doom-emacs = {
      inherit (p) emacsPackagesOverlay;
      enable = true;
      doomPrivateDir = ./doom.d;
      # emacsPackage = pkgs.emacsPgtk;
      # emacsPackage = pkgs.emacsPgtkGcc; # very slow build
    };
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
}
