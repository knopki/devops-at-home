{ config, lib, pkgs, user, ... }:
with lib;
let
  eopkgs = pkgs.emacsOverlay.emacsPackagesFor pkgs.emacs;
  depsFonts = with pkgs; [
    emacs-all-the-icons-fonts
    fira-code-symbols
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    source-sans-pro
  ];
  depsPythonDev = with pkgs; [
    python37Packages.flake8
    python37Packages.pyflakes
    python37Packages.pylint
    python37Packages.pyls-black
    python37Packages.pyls-mypy
    python37Packages.python-language-server
  ];
in
{
  options.local.emacs = { enable = mkEnableOption "enable emacs for user"; };

  config = mkIf config.local.emacs.enable {
    home.file = {
      ".emacs".source = "${pkgs.chemacs}/.emacs";
      ".emacs-profiles.el".text = ''
        (("default" . ((user-emacs-directory . "~/.emacs.d.doom")
                       (env . (("DOOMDIR" . "~/.doom.d")))))
        ("old" . ((user-emacs-directory . "~/.emacs.d.old"))))
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
      unstable.nodePackages.dockerfile-language-server-nodejs

      # editorconfig
      python37Packages.editorconfig

      # erlang
      erlang

      # flyspell
      hunspell
      hunspellDicts.en-us-large
      hunspellDicts.ru-ru

      # go
      master.gopls
      gocode
      gomodifytags
      gotests

      # latex
      # FIXME: unstable.texlab
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
      nixfmt
      nixpkgs-fmt

      # org
      gnuplot

      # php
      php
      php73Packages.php-cs-fixer

      # rust
      cargo
      unstable.clippy
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
      master.nodePackages.yaml-language-server
    ] ++ depsFonts ++ depsPythonDev;

    programs.emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        aggressive-indent
        all-the-icons
        all-the-icons-dired
        all-the-icons-ibuffer
        all-the-icons-ivy-rich
        avy
        benchmark-init
        bind-key # required by use-package
        browse-at-remote
        company
        company-box
        # company-lsp
        company-prescient
        counsel
        counsel-projectile
        dap-mode
        diff-hl
        diminish # required by use-package
        direnv
        doom-modeline
        doom-themes
        evil
        evil-collection
        evil-commentary
        evil-goggles
        evil-magit
        evil-org
        evil-surround
        gcmh
        fira-code-mode
        flycheck
        flyspell-correct-ivy
        general
        git-timemachine
        gitattributes-mode
        gitconfig-mode
        gitignore-mode
        helpful
        hide-mode-line
        highlight-numbers
        hl-todo
        ibuffer-projectile
        ivy
        ivy-prescient
        ivy-rich
        ivy-yasnippet
        json-mode # needed by nix-mode
        live-py-mode
        lsp-ivy
        lsp-mode
        lsp-treemacs
        lsp-ui
        magit
        magit-todos
        minions
        mixed-pitch
        nix-mode
        no-littering
        org-cliplink
        org-download
        org-fancy-priorities
        org-journal
        org-plus-contrib
        org-superstar
        persistent-scratch
        prescient
        projectile
        python-black
        rainbow-delimiters
        reverse-im
        ripgrep
        russian-holidays
        solaire-mode
        toc-org
        treemacs
        undo-tree
        use-package
        vterm
        wakatime-mode
        which-key
        yasnippet
        yasnippet-snippets
      ];
      overrides = self: super: rec {
        inherit (self.melpaPackages)
          aggressive-indent
          all-the-icons
          doom-themes
          evil-magit
          magit
          toc-org
          use-package
          ;
        inherit (eopkgs.melpaStablePackages)
          all-the-icons-ibuffer
          all-the-icons-ivy-rich
          lsp-ui
          org-superstar
          projectile
          ;
        inherit (eopkgs.melpaPackages)
          doom-modeline
          evil-collection
          fira-code-mode
          flycheck
          lsp-mode
          org-download
          reverse-im
          yasnippet-snippets
          ;
        inherit (eopkgs.elpaPackages) undo-tree;
      };
    };
  };
}
