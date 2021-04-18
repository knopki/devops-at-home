;;; +checkers.el --- Checkers -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Spell

(when (featurep! :checkers spell)
  ;; Disable spellchecking auto run in some modes.
  (remove-hook! '(org-mode-hook markdown-mode-hook) #'flyspell-mode)

  ;; Improve Emacs flyspell responsiveness using idle timers.
  (after! flyspell-lazy (flyspell-lazy-mode t)))

;; Setup multi-dictionary
(when (featurep! :checkers spell +hunspell)
  (after! ispell
    (setq ispell-dictionary "en_US,ru_RU")
    (ispell-set-spellchecker-params)
    (ispell-hunspell-add-multi-dic "en_US,ru_RU")))

;;; Grammar
(setq langtool-bin "languagetool-commandline")

;;; Syntax

;; Disable checking in some modes
(setq flycheck-global-modes
      '(not org-mode text-mode outline-mode fundamental-mode
            shell-mode eshell-mode term-mode vterm-mode))

;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; +checkers.el ends here
