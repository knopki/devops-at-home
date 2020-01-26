{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.emacs = { enable = mkEnableOption "enable emacs for user"; };

  config = mkIf config.local.emacs.enable {
    home.packages = with pkgs; [
      emacs-all-the-icons-fonts
      hunspell
      hunspellDicts.en-us-large
      hunspellDicts.ru-ru
      ripgrep
    ];

    programs.emacs = {
      enable = true;
      extraPackages = epkgs: (
        with epkgs.melpaStablePackages; [
          aggressive-indent
          all-the-icons
          avy
          benchmark-init
          bind-key # required by use-package
          company
          company-prescient
          company-quickhelp
          counsel
          counsel-projectile
          diminish # required by use-package
          evil-commentary
          evil-magit
          evil-surround
          flycheck
          flyspell-correct-ivy
          hide-mode-line
          ibuffer-projectile
          ivy
          ivy-prescient
          magit
          nyan-mode
          org-bullets
          org-sticky-header
          persistent-scratch
          persp-mode # delete?
          persp-mode-projectile-bridge # delete?
          prescient
          projectile
          ripgrep
          solaire-mode
          which-key
          yasnippet
          yasnippet-snippets
        ]
      ) ++ (
        with epkgs.melpaPackages; [
          company-fuzzy
          company-tabnine
          dashboard
          doom-modeline
          doom-themes
          evil
          evil-collection
          evil-goggles
          evil-org
          general
          ivy-rich
          ivy-yasnippet
          no-littering
          org-fancy-priorities
          use-package
        ]
      ) ++ (
        with epkgs.elpaPackages; [
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
