{ config, lib, pkgs, user, ... }:
with lib; {
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
    ];

    programs.emacs = {
      enable = true;
      extraPackages = epkgs: (
        with epkgs.melpaStablePackages; []
      ) ++ (
        with epkgs.melpaPackages; [
          aggressive-indent
          all-the-icons
          all-the-icons-dired
          avy
          benchmark-init
          bind-key # required by use-package
          browse-at-remote
          company
          company-box
          company-lsp
          company-prescient
          counsel
          counsel-projectile
          dap-mode
          dashboard
          diff-hl
          diminish # required by use-package
          direnv
          doom-modeline
          doom-themes
          evil
          evil-commentary
          evil-collection
          evil-goggles
          evil-magit
          evil-org
          evil-surround
          flycheck
          flyspell-correct-ivy
          general
          gitattributes-mode
          gitconfig-mode
          gitignore-mode
          git-timemachine
          helpful
          hide-mode-line
          hl-todo
          ibuffer-projectile
          ivy
          ivy-prescient
          ivy-rich
          ivy-yasnippet
          json-mode # needed by nix-mode
          nix-mode
          no-littering
          live-py-mode
          lsp-ivy
          lsp-mode
          lsp-treemacs
          lsp-ui
          magit
          magit-todos
          minions
          org-bullets
          org-fancy-priorities
          org-sticky-header
          persistent-scratch
          prescient
          projectile
          python-black
          reverse-im
          ripgrep
          solaire-mode
          toc-org
          treemacs
          use-package
          which-key
          yasnippet
          yasnippet-snippets
        ]
      ) ++ (
        with epkgs.elpaPackages; [
          gnu-elpa-keyring-update
          undo-tree
        ]
      ) ++ (
        with epkgs.orgPackages; [
          org-plus-contrib
        ]
      );
    };
  };
}
