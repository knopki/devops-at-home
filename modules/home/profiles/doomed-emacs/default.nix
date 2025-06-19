{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # emacs
    binutils # native-comp needs 'as', provided by this

    # doom dependencies
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

  programs = {
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
}
