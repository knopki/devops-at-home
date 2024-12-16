;;; +editor.el --- Editon -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Default

;; Move selected block up and down
(map! :v "J" #'drag-stuff-down
      :v "K" #'drag-stuff-up)

;;; Evil

;; Setup leaders keys.
(setq doom-leader-key "SPC"
      doom-leader-alt-key "M-SPC"
      doom-localleader-key ","
      doom-localleader-alt-key "M-,"

      ;; Work with visual lines, not logical.
      evil-respect-visual-line-mode t
      ;; Whether to setup Evil bindings in the minibuffer.
      evil-collection-setup-minibuffer t

      ;; Switch to the new window after splitting
      evil-split-window-below t
      evil-vsplit-window-right t)



(after! evil-ex
  ;; Kill buffer without window
  (evil-ex-define-cmd "bd[elete]" #'kill-this-buffer))


;;; Reverse Input Mode

;; Overrides function-key-map for preferred input-method to translate input
;; sequences to English, so we can use Emacs bindings while the non-default
;; system layout is active.
(use-package! reverse-im
  :after evil
  :custom
  (reverse-im-input-methods '("russian-computer"))
  :config
  (reverse-im-mode t))

;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; +editor.el ends here
