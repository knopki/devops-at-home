;;; +org.el --- Org configuration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; org-ql queries
(defvar knopki/org-ql-next-items-query
  '(and (todo "NEXT")
        (not (scheduled))
        (or (not (deadline))
            (deadline auto))))

(defvar knopki/org-ql-waiting-query
  '(and (todo "WAIT" "HOLD") (not (scheduled))))

(defvar knopki/org-ql-started-query '(todo "STRT"))

(defvar knopki/my-main-agenda-command
  '((agenda ""
            ((org-agenda-start-day "0d")
             (org-agenda-span 'day)
             (org-agenda-remove-tags t)
             (org-agenda-use-time-grid nil)
             (org-agenda-overriding-header "")
             (org-agenda-prefix-format " %-15 c%?12 t%?18 s")
             (org-agenda-deadline-leaders '("" "In %2dd:" "%2dd ago:"))
             (org-agenda-scheduled-leaders '("" "%2dd ago:"))
             (org-super-agenda-groups
              '((:order 5 :log t)
                (:order 1 :habit t)
                (:name ""
                 :order 0
                 :scheduled today
                 :date today)
                (:name "Overdue"
                 :order 2
                 :scheduled past
                 :deadline past)
                (:name "Coming Deadlines"
                 :order 3
                 :deadline future)
                (:name "Birthdays & holidays"
                 :order 4
                 :category "birthdays"
                 :category "holidays")))))

    (org-ql-block knopki/org-ql-started-query
                  ((org-ql-block-header "Started")))

    (org-ql-block knopki/org-ql-next-items-query
                  ((org-ql-block-header "Next Actions")))

    (org-ql-block knopki/org-ql-waiting-query
                  ((org-ql-block-header "Waiting")))))


;;; Larger heading sizes
(after! org
  (set-face-attribute 'org-document-title nil :height 1.5)
  (set-face-attribute 'org-level-1 nil :height 1.4)
  (set-face-attribute 'org-level-2 nil :height 1.3)
  (set-face-attribute 'org-level-3 nil :height 1.2)
  (set-face-attribute 'org-level-4 nil :height 1.1))

;;; Hooks and timers
(after! org
  (add-hook! 'org-mode-hook
    (defun my-org-mode-hook ()
      (setq display-line-numbers nil)
      (mixed-pitch-mode t)
      (knopki/org-insert-created-insinuate)))

  ;; Autosave (no sure is it worth it)
  (run-with-idle-timer 300 t 'org-save-all-org-buffers)

  ;; Auto save on archiving
  (add-hook! 'org-archive-hook #'org-save-all-org-buffers))

;;; Paths
(setq! org-directory "~/org/"
       org-archive-location (concat org-directory "archive/%s_archive::datetree/")
       org-roam-directory (concat org-directory "roam/")
       reftex-default-bibliography '("~/library/refs.bib")
       bibtex-completion-library-path "~/library"
       bibtex-completion-bibliography '("~/library/refs.bib")
       bibtex-completion-notes-path (concat org-roam-directory "refs"))

;;; Trivial configuration
(after! org
  (setq org-startup-folded 'content
        org-log-done 'time
        org-log-redeadline 'time
        org-log-reschedule 'time
        org-log-into-drawer t
        org-pretty-entities t
        org-enforce-todo-checkbox-dependencies t
        org-extend-today-until 5
        org-ellipsis "⤵"
        org-startup-with-inline-images t
        org-startup-truncated nil
        org-refile-use-cache t
        org-superstar-special-todo-items t
        org-global-properties
        '(("Effort_ALL". "0 0:10 0:20 0:30 1:00 2:00 3:00 4:00 6:00 8:00"))
        org-file-apps '(("\\.pdf::\\([0-9]+\\)?\\'" . "zathura %s -P %1")
                        ("\\.pdf\\'" . "zathura %s")
                        ("epub" . "zathura %s")
                        ("html" . default)
                        ("png" . "imv %s")
                        ("jpg" . "imv %s")
                        ("jpeg" . "imv %s")
                        ("gif" . "imv %s")
                        (directory . emacs)
                        (remote . emacs)
                        (auto-mode . emacs)))

  (add-to-list 'org-modules 'org-habit)
  (add-to-list 'org-modules 'org-checklist)

  (map! :map org-mode-map
        :localleader
        (:prefix ("d" . "date/deadline")
         "c" #'knopki/org-insert-created-at-point
         "r" #'knopki/org-insert-reviewed-at-point)))

;;; Keywords
(after! org
  (setq org-todo-keywords
        '((sequence
           "TODO(t)"    ; A task that needs doing
           "NEXT(n)"    ; Next action
           "STRT(s)"    ; A task that is in progress
           "WAIT(w)"    ; Something external is holding up this task
           "HOLD(h)"    ; This task is paused/on hold because of me
           "|"
           "DONE(d)"    ; Task successfully completed
           "KILL(k)"))  ; Task was cancelled, aborted or is no longer applicable
        org-todo-keyword-faces
        '(("STRT" . +org-todo-active)
          ("WAIT" . +org-todo-onhold)
          ("HOLD" . +org-todo-onhold))))


;;; Capture
(after! org
  (setq org-capture-templates
        `(("t" "Personal todo" entry
           (file+headline +org-capture-todo-file "Inbox")
           ,(concat "* TODO %?\n"
                    ":PROPERTIES:\n:CREATED: %U\n:END:\n"
                    "%i\n"
                    "%a")
           :jump-to-captured t)
          ("n" "Personal notes" entry
           (file+headline +org-capture-notes-file "Inbox")
           ,(concat "* %?\n"
                    ":PROPERTIES:\n:CREATED: %U\n"
                    "%i\n"
                    "%a")
           :jump-to-captured t)

          ;; Will use {org-directory}/{projectname}.pro.org and store
          ;; these under {ProjectName}/{Tasks,Notes,Changelog} headings. They
          ;; support `:parents' to specify what headings to put them under, e.g.
          ;; :parents ("Projects")
          ("p" "Centralized templates for projects")
          ("pt" "Project todo" entry
           (function knopki/+org-capture-central-project-file)
           ,(concat "* TODO %?\n"
                    ":PROPERTIES:\n:CREATED: %U\n"
                    ":END:\n"
                    "%i\n"
                    "%a")
           :heading "Tasks"
           :jump-to-captured t)
          ("pn" "Project notes" entry
           (function knopki/+org-capture-central-project-file)
           ,(concat "* %?\n"
                    ":PROPERTIES:\n:CREATED: %U\n:END:\n"
                    "%i\n"
                    "%a")
           :heading "Notes"
           :jump-to-captured t)
          ("pc" "Project changelog" entry
           (function knopki/+org-capture-central-project-file)
           ,(concat "* %U %?\n"
                    ":PROPERTIES:\n:CREATED: %U\n:END:\n"
                    "%i\n"
                    "%a")
           :heading "Changelog"
           :prepend t
           :jump-to-captured t)

          ;; Capture from browser via org-protocol
          ("b" "Browser Capture (selection)" entry
           (file+headline +org-capture-notes-file "Inbox")
           ,(concat "* %^{Title}%?\n"
                    ":PROPERTIES:\n:CREATED: %U\n:END:\n"
                    "Source: [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n"
                    "#+BEGIN_QUOTE\n%i\n#+END_QUOTE\n")
           :jump-to-captured t)
          ("B" "Browser Capture (link)" entry
           (file+headline +org-capture-notes-file "Inbox")
           ,(concat "* [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]%?\n"
                    ":PROPERTIES:\n:CREATED: %U\n:END:")
           :jump-to-captured t)
          )))

;;; Agenda
(after! org-agenda
  (setq org-agenda-text-search-extra-files '('agenda-archives)
        org-agenda-skip-deadline-prewarning-if-scheduled t
        org-agenda-skip-scheduled-if-deadline-is-shown t
        org-agenda-show-all-dates nil
        org-agenda-sticky t
        org-agenda-start-with-log-mode t
        org-agenda-insert-diary-extract-time t
        org-agenda-compact-blocks nil
        ;; Disable stuck projects mechanics
        org-stuck-projects (quote ("" nil nil ""))
        org-agenda-default-appointment-duration 60))

(use-package! org-ql
  :after org
  :init
  (map! :map doom-leader-open-map
        :desc "Org Agenda" "A" (cmd! (org-ql-view "Today Agenda"))
        :desc "Org Agendas" "a" #'org-ql-view)
  (map! :map doom-leader-notes-map
        :desc "Org Agendas" "a" #'org-ql-view
        :desc "org-ql search" "v" #'org-ql-search)
  :config
  (set-popup-rules!
    '(("^\\*Org QL View" :side right :width +popup-shrink-to-fit :quit 'current :select t :modeline nil :vslot -1)
      ("^\\*Org QL View: Now" :side right :width 0.4 :quit 'current :select t :modeline nil :vslot 2)))
  (setq org-ql-views
        (list (cons "Today Agenda" #'knopki/org-ql-today-agenda)

              (cons "Quick Tasks" #'knopki/org-ql-quick-tasks)
              (cons "Project View" #'knopki/org-ql-project-view)
              (cons "Next actions" #'knopki/org-ql-next-items)
              (cons "Waiting" #'knopki/org-ql-waiting)
              (cons "Started" #'knopki/org-ql-started)

              (cons "Calendar: Next week" #'knopki/org-ql-next-week)
              (cons "Calendar: This week" #'knopki/org-ql-this-week)
              (cons "Calendar: Previous week" #'knopki/org-ql-prev-week)
              (cons "Calendar: 3 weeks" #'knopki/org-ql-3-weeks)
              (cons "Calendar: Next month" #'knopki/org-ql-next-month)
              (cons "Calendar: This month" #'knopki/org-ql-this-month)
              (cons "Calendar: Previous month" #'knopki/org-ql-prev-month)
              (cons "Calendar: Next year" #'knopki/org-ql-next-year)
              (cons "Calendar: This year" #'knopki/org-ql-this-year)
              (cons "Calendar: Previous year" #'knopki/org-ql-prev-year)

              (cons "Review: Refile" #'knopki/org-ql-refile)
              (cons "Review: Stuck projects" #'knopki/org-ql-stuck-projects)
              (cons "Review: Stale tasks" #'knopki/org-ql-stale-tasks)
              (cons "Review: Dangling tasks" #'knopki/org-ql-dangling-tasks)
              (cons "Review: Recently timestamped" #'org-ql-view-recent-items)
              (cons "Review: To Archive" #'knopki/org-ql-to-archive))))


(use-package! org-super-agenda
  :after org-agenda
  :init
  (setq org-agenda-custom-commands
        `(("t" "Today Agenda" ,knopki/my-main-agenda-command)))
  :config
  ;; don't break evil on org-super-agenda headings
  ;; see https://github.com/alphapapa/org-super-agenda/issues/50
  (setq org-super-agenda-header-map nil)
  (org-super-agenda-mode))

;;; Attachments
(after! org-download
  (setq org-download-screenshot-method "grimshot save area %s"))

;;; org-roam
(after! org-roam
  (setq org-roam-capture-templates
        `(("d" "default" plain #'org-roam-capture--get-point
           "%?"
           ;; :file-name "%<%Y%m%d%H%M%S>-${slug}"
           :file-name "${slug}"
           :head ,(concat
                   "#+TITLE: ${title}\n"
                   "- tags :: \n"
                   "- keywords :: ${keywords}\n\n")
           :unnarrowed t))))

;;; Bibtex and org-roam integration
(setq +knopki/ref-template
      (concat
       "${title}\n"
       "#+ROAM_KEY: cite:${=key=}\n"
       "#+ROAM_TAGS: references ${keywords}\n"
       "- tags :: \n"
       "- keywords :: ${keywords}\n"
       "- source :: ${url}\n\n"
       "* ${title}\n"
       "  :PROPERTIES:\n"
       "  :CUSTOM_ID: ${=key=}\n"
       "  :URL: ${url}\n"
       "  :AUTHOR: ${author-or-editor}\n"
       "  :END:\n\n"))

(after! bibtex-completion
  (add-to-list 'ivy-re-builders-alist '(ivy-bibtex . ivy--regex-plus))
  (setq bibtex-completion-pdf-extension '(".pdf" ".djvu" ".epub" ".html")
        bibtex-completion-bibliography reftex-default-bibliography)
  (setq bibtex-completion-pdf-open-function 'org-open-file
        bibtex-completion-notes-template-multiple-files +knopki/ref-template))

(use-package! org-ref
  :after (org-roam bibtex-completion)
  :config
  (require 'org-ref-ivy)
  ;; same paths
  (setq org-ref-pdf-directory bibtex-completion-library-path
        org-ref-notes-directory bibtex-completion-notes-path
        org-ref-default-bibliography bibtex-completion-bibliography)
  (setq org-ref-get-pdf-filename-function #'org-ref-get-pdf-filename-helm-bibtex
        org-ref-open-pdf-function 'org-ref-open-pdf-at-point))

(use-package! org-roam-bibtex
  :after org-roam
  :hook (org-roam-mode . org-roam-bibtex-mode)
  :commands (orb-insert orb-note-actions)
  :config
  (require 'orb-ivy)
  (setq orb-insert-frontend 'ivy-bibtex
        orb-note-actions-frontend 'ivy
        orb-preformat-keywords
        '("=key=" "title" "url" "author-or-editor" "keywords")
        orb-templates
        `(("r" "ref" plain #'org-roam-capture--get-point "%?"
           :file-name "refs/${=key=}"
           :head ,(concat "#+TITLE: " +knopki/ref-template)
           :unnarrowed t
           :immediate-finish t))))


(provide 'org-config)
;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; +org.el ends here
