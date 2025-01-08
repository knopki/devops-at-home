;;; +core.el --- Core -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;; Delete files to trash, as an extra layer of precaution against accidentally
;; deleting wanted files.
(setq delete-by-moving-to-trash t)

;; Point goes to the last place where it was when you previously visited
;; the same file.
(after! saveplace (save-place-mode t))


;;; Keybindings

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

;;; Files

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

;;; Recenf
(after! recentf
  (recentf-load-list)
  (run-at-time nil (* 60 60) #'recentf-save-list)) ; every 60 mins


;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; +core.el ends here
