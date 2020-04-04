{ config, lib, pkgs, user, ... }:
with lib;
let
  eopkgs = pkgs.emacsOverlay.emacsPackagesFor pkgs.emacs;
in
{
  options.local.emacs = { enable = mkEnableOption "enable emacs for user"; };

  config = mkIf config.local.emacs.enable {
    home.file = {
      # HACK: support virtualenv and nix shells
      ".pylintrc".text = ''
        [MASTER]
        init-hook='import os,sys;[sys.path.append(p) for p in os.environ.get("PYTHONPATH","").split(":")];'
      '';
    };

    home.packages = with pkgs; [
      emacs-all-the-icons-fonts
      hunspell
      hunspellDicts.en-us-large
      hunspellDicts.ru-ru
      python37Packages.flake8
      python37Packages.pyflakes
      python37Packages.pylint
      python37Packages.pyls-black
      python37Packages.pyls-mypy
      python37Packages.python-language-server
      ripgrep
      texlive.combined.scheme-medium
      wakatime
    ];

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
        flycheck
        flyspell-correct-ivy
        general
        git-timemachine
        gitattributes-mode
        gitconfig-mode
        gitignore-mode
        gnu-elpa-keyring-update
        helpful
        hide-mode-line
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
        nix-mode
        no-littering
        org-bullets
        org-cliplink
        org-download
        org-fancy-priorities
        org-journal
        org-plus-contrib
        persistent-scratch
        prescient
        projectile
        python-black
        reverse-im
        ripgrep
        solaire-mode
        toc-org
        treemacs
        undo-tree
        use-package
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
          org-bullets
          toc-org
          use-package
          ;
        inherit (eopkgs.melpaStablePackages)
          all-the-icons-ibuffer
          all-the-icons-ivy-rich
          lsp-ui
          projectile
          ;
        inherit (eopkgs.melpaPackages)
          doom-modeline
          evil-collection
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
