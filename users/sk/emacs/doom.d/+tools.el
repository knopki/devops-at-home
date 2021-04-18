;;; +tools.el --- Tools -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; LSP

(after! lsp-mode
  (setq lsp-idle-delay 1.0
        lsp-file-watch-threshold 10000)
  (add-to-list 'lsp-file-watch-ignored "/nix/store"))

;;; Wakatime

;; WakaTime measures coding time for programmers using open-source plugins for
;; your text editor.
(use-package! wakatime-mode
  :after-call doom-after-switch-buffer-hook after-find-file
  :config
  (global-wakatime-mode t))


;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; +tools.el ends here
