;;; +tools.el --- Tools -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; LSP

(after! lsp-mode
  (setq lsp-idle-delay 1.0
        lsp-file-watch-threshold 10000)
  (add-to-list 'lsp-file-watch-ignored "/nix/store"))

;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; +tools.el ends here
