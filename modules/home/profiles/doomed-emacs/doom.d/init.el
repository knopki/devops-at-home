;;; init.el -- Doom's init -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(doom! :input
       :completion
       (company +childframe)
       (vertico +childframe +icons)
       :ui
       doom
       ;; doom-dashboard
       doom-quit
       hl-todo
       (ligatures +fira +extra)
       modeline
       ophints
       (popup +defaults)
       treemacs
       vc-gutter
       vi-tilde-fringe
       (window-select +switch-window)
       workspaces
       zen ;; mixed-pitch!
       :editor
       (evil +everywhere)
       file-templates
       fold
       format
       snippets
       :emacs
       (dired +icons)
       electric
       (ibuffer +icons)
       undo
       vc
       :term
       :checkers
       syntax
       (spell +aspell)
       :tools
       debugger
       direnv
       editorconfig
       (eval +overlay)
       gist
       (lookup +dictionary)
       (lsp +peek)
       magit
       make
       rgb
       tmux
       tree-sitter
       upload
       :lang
       data
       emacs-lisp
       (json +lsp +tree-sitter)
       (markdown +grip)
       (sh +fish +lsp +tree-sitter)
       (yaml +lsp +tree-sitter)
       :os
       (tty +osc)
       :email
       :app
       :config
       (default +bindings +smartparens))

;; Until https://github.com/hlissner/doom-emacs/issues/2447 resolved
(setq evil-respect-visual-line-mode t)

;; Load nix based configuration
(load "default")

;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; init.el ends here
