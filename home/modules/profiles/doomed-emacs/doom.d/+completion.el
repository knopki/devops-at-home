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

(map! :when (modulep! :completion company)
      :after company
      :map company-mode-map
      :i [C-return] #'company-complete-selection)

;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; +completion.el ends here
