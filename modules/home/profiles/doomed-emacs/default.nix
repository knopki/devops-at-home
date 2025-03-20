{
  config,
  lib,
  pkgs,
  nixosConfig,
  inputs,
  ...
}:
let
  inherit (lib) listToAttrs nameValuePair;
in
{
  home.packages = with pkgs; [
    # emacs
    binutils # native-comp needs 'as', provided by this

    # doom dependencies
    git
    (ripgrep.override { withPCRE2 = true; })
    gnutls # for TLS connectivity

    # # optional dependencies
    fd # faster projectile indexing
    imagemagick # for image-dired
    pinentry-emacs # in-emacs gnupg prompts
    zstd # for undo-fu-session/undo-tree compression

    ## modules dependencies
    # :checkers spell
    (aspellWithDicts (
      ds: with ds; [
        en
        en-computers
        en-science
        ru
      ]
    ))

    # :tools editorconfig
    editorconfig-core-c

    # :tools lookup & :lang org +roam
    sqlite

    # :lang json
    vscode-langservers-extracted

    # :lang markdown
    nodePackages.markdownlint-cli
    pandoc
    proselint
    python3Packages.grip

    # :lang sh
    bashdb
    nodePackages.bash-language-server
    shellcheck
    shfmt

    # lang: yaml
    nodePackages.yaml-language-server
  ];

  home.file.".doom.d" = {
    target = "${config.xdg.configHome}/doom";
    source = ./doom.d;
    recursive = true;
  };

  home.sessionVariables = {
    EDITOR = "emacs -nw";
    VISUAL = "emacsclient -a='emacs -nw' -c";
  };

  programs = {
    imv.enable = true;
    zathura.enable = true;
    emacs = {
      enable = true;
      # package =
      extraPackages =
        epkgs: with epkgs; [
          reverse-im
          lark-mode
          vterm
        ];
      # overrides = self: super: rec {
      #   haskell-mode = self.melpaPackages.haskell-mode;
      #   # ...
      # };
      extraConfig = ''

      '';
    };
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    socketActivation.enable = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = (
      listToAttrs (
        map (x: nameValuePair x "emacsclient.desktop") [
          "application/javascript"
          "application/json"
          "application/markdown"
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
    );
  };
}
