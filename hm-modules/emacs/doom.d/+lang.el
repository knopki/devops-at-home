;;; +lang.el --- Languages -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Nix

;; Prefer nixpkgs-fmt from shell nix
(setq nix-nixfmt-bin "nixpkgs-fmt")

;;; PlantUML
(after! plantuml-mode
  (setenv "_JAVA_OPTIONS")
  (setq plantuml-default-exec-mode 'executable
        plantuml-output-type "png")
  (set-popup-rule! "^\\*PLANTUML" :select t :height 40))

;;; Python
(after! lsp-pyright
  (setq lsp-pyright-multi-root nil)
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]\\.venv\\'"))


;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; +lang.el ends here
