;;; org-config.el --- Org configuration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun knopki/org-get-timestamp-time (POM &optional INHERIT)
  "Get the timestmap from POM and format it for org-schedule.
If INHERIT is not-nil, then also check higher levels of the hierarchy"
  (let ((time (org-entry-get POM "TIMESTAMP" INHERIT)))
    (when time
      (org-time-string-to-time time))))

(defun knopki/org-agenda-prefix-format-s (POINT FORMAT)
  "Get some timestamp from POINT and FORMAT it."
  (let ((time (or (org-get-scheduled-time POINT)
                  (org-get-deadline-time POINT)
                  (knopki/org-get-timestamp-time POINT))))
    (when time (format-time-string FORMAT time))))

(defun knopki/org-agenda-tags-limit-dates (START REL)
  "Org agenda date range query from START till REL."
  `(let* ((ts-start (org-read-date nil nil ,START))
          (ts-end (org-read-date nil nil ,REL nil (org-read-date nil t ts-start))))
     (concat (format "+DEADLINE>=\"<%s>\"" ts-start)
             (format "+DEADLINE<\"<%s>\"" ts-end)
             "|"
             (format "+SCHEDULED>=\"<%s>\"" ts-start)
             (format "+SCHEDULED<\"<%s>\"" ts-end)
             "|"
             (format "+CLOSED>=\"<%s>\"" ts-start)
             (format "+CLOSED<\"<%s>\"" ts-end)
             "|"
             (format "+TIMESTAMP>=\"<%s>\"" ts-start)
             (format "+TIMESTAMP<\"<%s>\"" ts-end))))

(defmacro knopki/org-agenda-tags-limit-dates-macro
    (START-FORMAT END &optional START-OFFSET)
  "Org agenda date range query aligned to calendar.
Start at START-FORMAT with optional START-OFFSET till END."
  `(let ((start
          (if ,START-OFFSET
              (org-read-date nil nil ,START-OFFSET nil
                             (org-read-date nil t (format-time-string ,START-FORMAT)))
            (format-time-string ,START-FORMAT))))
     (knopki/org-agenda-tags-limit-dates start ,END)))

(defun knopki/org-agenda-command-date-range-opts (TITLE DATE-FORMAT)
  "Agenda options for date range block.
Customized by TITLE and DATE-FORMAT."
  `((org-agenda-overriding-header ,TITLE)
    (org-agenda-prefix-format
     (concat
      " %-15 c%12(or (knopki/org-agenda-prefix-format-s (point) \""
      ,DATE-FORMAT
      "\") \"\") "))
    (org-agenda-sorting-strategy-selected '(time-up priority-down category-keep))
    ;; TODO: https://github.com/alphapapa/org-super-agenda/pull/167
    (org-super-agenda-retain-sorting t)
    (org-super-agenda-groups
     '((:discard(:habit t))
       (:order 10 :todo "DONE" :todo "KILL" :log 'closed :name "Closed")
       (:order 1 :scheduled t :date t :name "Scheduled")
       (:order 2 :deadline t :name "Deadlines")))))


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
      (org-expiry-insinuate)))

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
        org-file-apps '((auto-mode . emacs)
                        ("\\.pdf::\\([0-9]+\\)?\\'" . "zathura %s -P %1")
                        ("\\.pdf\\'" . "zathura %s")
                        ("html" . default)
                        (directory . emacs)))
  (add-to-list 'org-modules 'org-habit)
  (add-to-list 'org-modules 'org-checklist))

;;; Keywords
(after! org
  (setq org-todo-keywords
        '((sequence
           "TODO(t)"    ; A task that needs doing
           "NEXT(n)"    ; Next action
           "STRT(s)"    ; A task that is in progress
           "WAIT(w)"    ; Something external is holding up this task
           "HOLD(h)"    ; This task is paused/on hold because of me
           ;; "PROJ(p)"    ; A project, which usually contains other tasks
           "|"
           "DONE(d)"    ; Task successfully completed
           "KILL(k)"))  ; Task was cancelled, aborted or is no longer applicable
        org-todo-keyword-faces
        '(("STRT" . +org-todo-active)
          ("WAIT" . +org-todo-onhold)
          ("HOLD" . +org-todo-onhold)
          ;; ("PROJ" . +org-todo-project)
          )))


;;; Capture
(after! org
  (defun knopki/+org-capture-central-project-file ()
    "Org Capture central project file function."
    (+org--capture-central-file
     (format "%s.pro.org" (projectile-project-name))
     (projectile-project-name)))

  (defun transform-square-brackets-to-round-ones (STRING)
    "Transforms [ into ( and ] into ) in STRING, other chars left unchanged."
    (concat
     (mapcar #'(lambda (c) (if (equal c ?\[) ?\( (if (equal c ?\]) ?\) c)))
             STRING)))

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

(use-package! org-super-agenda
  :after org-agenda
  :init
  (setq org-agenda-custom-commands
        `(("p" "Planner"
           (
            ;; Today Agenda
            (agenda ""
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

            ;; Started
            (org-ql-block '(todo "STRT") ((org-ql-block-header "Started")))

            ;; Next Actions
            (org-ql-block '(and (todo "NEXT")
                                (not (scheduled))
                                (or (not (deadline))
                                    (deadline auto)))
                          ((org-ql-block-header "Next Actions")))

            ;; Waiting
            (org-ql-block '(and (todo "WAIT" "HOLD") (not (scheduled)))
                          ((org-ql-block-header "Waiting")))

            ;; Stuck Projects
            (org-ql-block '(and (todo)
                                (org-entry-blocked-p)
                                (descendants)
                                (not (descendants (todo "NEXT")))
                                (not (descendants (todo "STRT"))))
                          ((org-ql-block-header "Stuck Projects")))

            ;; Quick Tasks
            (org-ql-block '(and (todo)
                                (property "Effort")
                                (not (scheduled))
                                (or (not (deadline))
                                    (deadline auto))
                                (>= 30
                                    (org-duration-to-minutes
                                     (org-entry-get (point) "Effort"))))
                          ((org-ql-block-header "Quick Tasks")))

            ;; Refile
            (org-ql-block '(or
                            (and (path "todo.org")
                                 (todo)
                                 (parent (heading "Inbox")))
                            (and (path "notes.org")
                                 (parent (heading "Inbox"))))
                          ((org-ql-block-header "Refile")))

            ;; This Week
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "W%V" "++1w")
                  ,(knopki/org-agenda-command-date-range-opts "This Week" "%a, %d"))

            ;; Next Week
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "W%V" "++1w" "++1w")
                  ,(knopki/org-agenda-command-date-range-opts "Next Week" "%a, %d"))))

          ("r" . "Review")
          ("rw" "Week Review"
           (
            ;; prev week
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "W%V" "++1w" "--1w")
                  ,(knopki/org-agenda-command-date-range-opts "Previous Week" "%a, %d"))
            ;; this week
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "W%V" "++1w")
                  ,(knopki/org-agenda-command-date-range-opts "This Week" "%a, %d"))
            ;; next week
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "W%V" "++1w" "++1w")
                  ,(knopki/org-agenda-command-date-range-opts "Next Week" "%a, %d"))))

          ("rm" "Month Review"
           (
            ;; prev month
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "%Y-%m-01" "++1m" "--1m")
                  ,(knopki/org-agenda-command-date-range-opts "Previous Month" "%a, %d"))
            ;; this month
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "%Y-%m-01" "++1m")
                  ,(knopki/org-agenda-command-date-range-opts "This Month" "%a, %d"))
            ;; next month
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "%Y-%m-01" "++1m" "++1m")
                  ,(knopki/org-agenda-command-date-range-opts "Next Month" "%a, %d"))))

          ("ry" "Year Review"
           (
            ;; next year
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "%Y-01-01" "++1y" "--1y")
                  ,(knopki/org-agenda-command-date-range-opts "Next Year" "%Y-%m-%d"))
            ;; this year
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "%Y-01-01" "++1y")
                  ,(knopki/org-agenda-command-date-range-opts "This Year" "%Y-%m-%d"))
            ;; next year
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "%Y-01-01" "++1y" "++1y")
                  ,(knopki/org-agenda-command-date-range-opts "Next Year" "%Y-%m-%d"))
            ))))
  :config
  ;; don't break evil on org-super-agenda headings
  ;; see https://github.com/alphapapa/org-super-agenda/issues/50
  (setq org-super-agenda-header-map nil)
  (org-super-agenda-mode))


;;; Attachments
(after! org-download
  (setq org-download-screenshot-method "grimshot save area %s"))

;;; Expire old entries
(use-package! org-expiry
  :commands (org-expiry-insinuate
             org-expiry-deinsinuate
             org-expiry-insert-created
             org-expiry-insert-expiry
             org-expiry-add-keyword
             org-expiry-archive-subtree
             org-expiry-process-entry
             org-expiry-process-entries)
  :config
  (setq org-expiry-inactive-timestamps t))

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
       "#+ROAM_KEY: ${=key=}\n"
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
  (setq org-ref-prefer-bracket-links t
        org-ref-get-pdf-filename-function #'org-ref-get-pdf-filename-helm-bibtex
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
        '("=key=" "title" "url" "file" "author-or-editor" "keywords")
        orb-templates
        `(("r" "ref" plain #'org-roam-capture--get-point
           "%?"
           :file-name "refs/${=key=}"
           :head ,(concat "#+TITLE: " +knopki/ref-template)
           :unnarrowed t
           :immediate-finish t))))


(provide 'org-config)
;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; org-config.el ends here
