;;; +ui.el --- UI -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Builtin

;; File dialogs via minibuffer only.
(setq use-file-dialog nil
      ;; Number of lines of margin at the top & bottom.
      scroll-margin 5)

;; Disable help mouse-overs for mode-line segments (i.e. `:help-echo' text)
;; They're generally unhelpful and only add confusing visual clutter.
(setq mode-line-default-help-echo nil
      show-help-function nil)

;; Expand the minibuffer to fit multi-line text displayed in the echo-area.
;; This doesn't look too great with direnv, however...
(setq resize-mini-windows 'grow-only)

;;; All the Icons

(after! all-the-icons
  ;; Additional icons.
  (setq all-the-icons-icon-alist
        `(,@all-the-icons-icon-alist
          ("\\.[bB][iI][nN]$" all-the-icons-octicon "file-binary" :v-adjust 0.0 :face all-the-icons-yellow)
          ("\\.c?make$" all-the-icons-fileicon "gnu" :face all-the-icons-dorange)
          ("\\.conf$" all-the-icons-octicon "settings" :v-adjust 0.0 :face all-the-icons-yellow)
          ("\\.toml$" all-the-icons-octicon "settings" :v-adjust 0.0 :face all-the-icons-yellow)
          ("\\.xpm$" all-the-icons-octicon "file-media" :v-adjust 0.0 :face all-the-icons-dgreen)
          ("\\.epub\\'" all-the-icons-faicon "book" :height 1.0 :v-adjust -0.1 :face all-the-icons-green)))
  (setq all-the-icons-mode-icon-alist
        `(,@all-the-icons-mode-icon-alist
          (xwidget-webkit-mode all-the-icons-faicon "chrome" :v-adjust -0.1 :face all-the-icons-blue)
          (diff-mode all-the-icons-octicon "git-compare" :v-adjust 0.0 :face all-the-icons-lred)
          (flycheck-error-list-mode all-the-icons-octicon "checklist" :height 1.1 :v-adjust 0.0 :face all-the-icons-lred)
          (elfeed-search-mode all-the-icons-faicon "rss-square" :v-adjust -0.1 :face all-the-icons-orange)
          (elfeed-show-mode all-the-icons-octicon "rss" :height 1.1 :v-adjust 0.0 :face all-the-icons-lorange)
          (conf-mode all-the-icons-octicon "settings" :v-adjust 0.0 :face all-the-icons-yellow)
          (conf-space-mode all-the-icons-octicon "settings" :v-adjust 0.0 :face all-the-icons-yellow)
          (forge-topic-mode all-the-icons-alltheicon "git" :face all-the-icons-blue)
          (helpful-mode all-the-icons-faicon "info-circle" :height 1.1 :v-adjust -0.1 :face all-the-icons-purple)
          (Info-mode all-the-icons-faicon "info-circle" :height 1.1 :v-adjust -0.1)
          (ein:notebooklist-mode all-the-icons-faicon "book" :face all-the-icons-lorange)
          (nov-mode all-the-icons-faicon "book" :height 1.0 :v-adjust -0.1 :face all-the-icons-green)
          (gfm-mode all-the-icons-octicon "markdown" :face all-the-icons-lblue))))


;; Visual bell in the modeline.
(after! doom-themes (doom-themes-visual-bell-config))

;;; Deft

;; remove deft key binding because there is no deft
(undefine-key! doom-leader-notes-map "d")


;;; Modeline

;; Use unicode when no icons.
(setq doom-modeline-unicode-fallback t
      ;; Just show unique buffer name.
      doom-modeline-buffer-file-name-style 'truncate-except-project
      ;; How to detect the project root.
      doom-modeline-project-detection 'project
      ;; What to dispaly as the version while a new one is being loaded.
      doom-modeline-env-load-string "♻")

;; Setup modeline fonts.
(custom-set-faces!
  '(mode-line :height 110)
  '(mode-line-inactive :height 110))

;;; Mixed Pitch

(after! mixed-pitch
  (pushnew! mixed-pitch-fixed-pitch-faces
            'markdown-code-face
            'markdown-comment-face
            'markdown-footnote-marker-face
            'markdown-gfm-checkbox-face
            'markdown-inline-code-face
            'markdown-language-info-face
            'markdown-language-info-properties
            'markdown-language-keyword-face
            'markdown-language-keyword-properties
            'markdown-markup-face
            'markdown-math-face
            'markdown-pre-face
            'org-checkbox-statistics-done
            'org-checkbox-statistics-todo
            'org-drawer
            'org-hide
            'org-indent
            'org-latex-and-related
            'org-link
            'org-list-checkbox
            'org-list-dt
            'org-scheduled-custom
            'org-scheduled-custom-braket
            'org-superstar-header-bullet
            'org-superstar-leading))

;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; +ui.el ends here
