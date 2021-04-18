;;; +completion.el --- Completion -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Company

;; Disable automatic completion start
(setq company-idle-delay nil
      ;; Number the candidates (use M-1, M-2 etc to select completions).
      company-show-numbers t
      ;; Selecting item <first|>last wraps around.
      company-selection-wrap-around t)

(map! :when (featurep! :completion company)
      :after company
      :map company-mode-map
      :i [C-return] #'company-complete-selection)


;;; Ivy

;; index/count format.
(setq ivy-count-format "(%d/%d)"
      ;; Add file-at-point to the list of candidates.
      counsel-find-file-at-point t
      ;; Separator for kill rings in counsel-yank-pop.
      counsel-yank-pop-separator "\n────────\n"
      ;; Use the faster search tool: ripgrep.
      counsel-grep-base-command
      (if (executable-find "rg")
          "rg -S --no-heading --line-number --color never '%s' %s"
        "grep -E -n -e %s %s"))

(after! ivy-prescient
  ;; A list of regex building funcs for each collection func.
  (pushnew! ivy-re-builders-alist
            '(counsel-pt . +ivy-prescient-non-fuzzy)
            '(counsel-grep . +ivy-prescient-non-fuzzy)
            '(counsel-imenu . +ivy-prescient-non-fuzzy)
            '(counsel-projectile-grep . +ivy-prescient-non-fuzzy)
            '(counsel-projectile-rg . +ivy-prescient-non-fuzzy)
            '(counsel-yank-pop . +ivy-prescient-non-fuzzy)
            '(projectile-grep . +ivy-prescient-non-fuzzy)
            '(projectile-ripgrep . +ivy-prescient-non-fuzzy)
            '(swiper-all . +ivy-prescient-non-fuzzy)
            '(lsp-ivy-workspace-symbol . +ivy-prescient-non-fuzzy)
            '(lsp-ivy-global-workspace-symbol . +ivy-prescient-non-fuzzy)
            '(insert-char . +ivy-prescient-non-fuzzy)
            '(counsel-unicode-char . +ivy-prescient-non-fuzzy)))


;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; +completion.el ends here
