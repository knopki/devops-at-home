;;; packages.el -- Doom Emacs private config -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Sergey Korolev"
      user-mail-address "korolev.srg@gmail.com")


;;; Core

;; Delete files to trash, as an extra layer of precaution against accidentally
;; deleting wanted files.
(setq delete-by-moving-to-trash t)

;; Point goes to the last place where it was when you previously visited
;; the same file.
(after! saveplace (save-place-mode t))

;;;; Keybindings

(after! which-key
  ;; Setup pretty symbols for `which-key'
  (setq which-key-allow-multiple-replacements t
        ;; Truncate to one char
        which-key-special-keys '("SPC" "TAB" "RET" "ESC" "DEL"))
  (appendq! which-key-replacement-alist
            '((("SPC") . ("␣"))
              (("TAB") . ("↹"))
              (("RET") . ("⏎"))
              (("ESC") . ("␛"))
              (("DEL") . ("⇤")))))

;;;; Files

;; Kill process without confirmation.
(setq confirm-kill-processes nil
      ;; Confirm before visiting a new file or buffer.
      confirm-nonexistent-file-or-buffer t
      ;; Make numeric backup versions unconditionally.
      version-control t
      ;; Backups of registered files are made as with other files.
      vc-make-backup-files t
      ;; Don't clobber symlinks.
      backup-by-copying t)

;;;; Recenf
(after! recentf
  (recentf-load-list)
  (run-at-time nil (* 60 60) #'recentf-save-list)) ; every 60 mins

;;; Completion
;;;; Company

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


;;;; Ivy

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
;;; UI
;;;; Builtin

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

;;;; All the Icons

(after! all-the-icons
  ;; Additional icons.
  (setq all-the-icons-icon-alist
        `(,@all-the-icons-icon-alist
          ("\\.[bB][iI][nN]$" all-the-icons-octicon "file-binary" :v-adjust 0.0 :face all-the-icons-yellow)
          ("\\.c?make$" all-the-icons-fileicon "gnu" :face all-the-icons-dorange)
          ("\\.conf$" all-the-icons-octicon "settings" :v-adjust 0.0 :face all-the-icons-yellow)
          ("\\.toml$" all-the-icons-octicon "settings" :v-adjust 0.0 :face all-the-icons-yellow)
          ("\\.xpm$" all-the-icons-octicon "file-media" :v-adjust 0.0 :face all-the-icons-dgreen)
          (".*\\.ipynb\\'" all-the-icons-fileicon "jupyter" :height 1.2 :face all-the-icons-orange)
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
          (ein:notebook-mode all-the-icons-fileicon "jupyter" :height 1.2 :face all-the-icons-orange)
          (ein:notebook-multilang-mode all-the-icons-fileicon "jupyter" :height 1.2 :face all-the-icons-dorange)
          (nov-mode all-the-icons-faicon "book" :height 1.0 :v-adjust -0.1 :face all-the-icons-green)
          (gfm-mode all-the-icons-octicon "markdown" :face all-the-icons-lblue))))


;;;; Theme and Fonts

;; Setup fonts.
(setq doom-font (font-spec :family "FiraCode Nerd Font Mono" :size 16)
      doom-variable-pitch-font (font-spec :family "Source Sans Pro"))

;; Visual bell in the modeline.
(after! doom-themes (doom-themes-visual-bell-config))

;;;; Modeline

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

;;;; Mixed Pitch

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

;;; Editor
;;;; Default

;; Move selected block up and down
(map! :v "J" #'drag-stuff-down
      :v "K" #'drag-stuff-up)

;;;; Evil

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


;;;; Reverse Input Mode

;; Overrides function-key-map for preferred input-method to translate input
;; sequences to English, so we can use Emacs bindings while the non-default
;; system layout is active.
(use-package! reverse-im
  :after evil
  :custom
  (reverse-im-input-methods '("russian-computer"))
  :config
  (reverse-im-mode t))

;;; Checkers
;;;; Spell

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

;;;; Grammar
(setq langtool-bin "languagetool-commandline")


;;;; Syntax

;; Disable checking in some modes
(setq flycheck-global-modes
      '(not org-mode text-mode outline-mode fundamental-mode
            shell-mode eshell-mode term-mode vterm-mode))

;;; Tools
;;;; LSP

(after! lsp-mode
  (setq lsp-idle-delay 1.0
        lsp-file-watch-threshold 10000)
  (add-to-list 'lsp-file-watch-ignored "/nix/store"))

;;;; Wakatime

;; WakaTime measures coding time for programmers using open-source plugins for
;; your text editor.
(use-package! wakatime-mode
  :after-call doom-after-switch-buffer-hook after-find-file
  :config
  (global-wakatime-mode t))

;;; Languages
;;;; Nix

;; Prefer nixpkgs-fmt from shell nix
(setq nix-nixfmt-bin "nixpkgs-fmt")

;;;; Org
(load! "org-config.el")

;;;; PlantUML
(after! plantuml-mode
  (setenv "_JAVA_OPTIONS")
  (setq plantuml-default-exec-mode 'executable
        plantuml-output-type "png")
  (set-popup-rule! "^\\*PLANTUML" :select t :height 40))

;;;; Python
(after! lsp-pyright
  (setq lsp-pyright-multi-root nil)
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]\\.venv\\'"))

;;; App
;;;; Calendar

(setq calendar-week-start-day 1
      calendar-day-name-array ["Воскресенье" "Понедельник" "Вторник" "Среда"
                               "Четверг" "Пятница" "Суббота"]
      calendar-day-header-array ["Вс" "Пн" "Вт" "Ср" "Чт" "Пт" "Сб"]
      calendar-day-abbrev-array ["Вск" "Пнд" "Втр" "Сре" "Чтв" "Птн" "Суб"]
      calendar-month-name-array ["Январь" "Февраль" "Март" "Апрель" "Май"
                                 "Июнь" "Июль" "Август" "Сентябрь"
                                 "Октябрь" "Ноябрь" "Декабрь"])

(after! calendar
  (use-package! russian-holidays
    :config
    (appendq! holiday-local-holidays russian-holidays)))

;;; Safe local variables
(setq safe-local-variable-values '((lsp-clients-flow-server . nil)
                                   (lsp-yaml-format-enable . nil)))

;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; config.el ends here
