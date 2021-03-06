;;; packages.el -- Doom Emacs private config -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Sergey Korolev"
      user-mail-address "korolev.srg@gmail.com")


(load! "+core")
(load! "+completion")
(load! "+ui")
(load! "+editor")
(load! "+checkers")
(load! "+tools")
(load! "+org")
(load! "+calendar")
(load! "+lang")

;;; Safe local variables
(setq safe-local-variable-values '((lsp-clients-flow-server . nil)
                                   (lsp-yaml-format-enable . nil)))

;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; config.el ends here
