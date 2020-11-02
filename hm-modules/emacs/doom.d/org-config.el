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
      "%20c %?11(or (knopki/org-agenda-prefix-format-s (point) \""
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
      (mixed-pitch-mode t)))

  ;; Autosave (no sure is it worth it)
  (run-with-idle-timer 300 t 'org-save-all-org-buffers)

  ;; Auto save on archiving
  (add-hook! 'org-archive-hook #'org-save-all-org-buffers))

;;; Paths
(after! org
  (setq org-archive-location (concat org-directory "archive/%s_archive::datetree/")
        org-roam-directory (concat org-directory "notes/")
        org-roam-db-location (concat doom-cache-dir "org-roam.db")))

;;; Trivial configuration
(after! org
  (setq org-modules '(org-checklist org-habit)
        org-startup-folded 'content
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
        '(("Effort_ALL". "0 0:10 0:20 0:30 1:00 2:00 3:00 4:00 6:00 8:00"))))

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
  ;; don't break evil on org-super-agenda headings
  ;; see https://github.com/alphapapa/org-super-agenda/issues/50
  (setq org-super-agenda-header-map nil)
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
                     (org-agenda-prefix-format "%20c %?11 t%?12 s")
                     (org-agenda-deadline-leaders '("" "In %2dd:" "%2dd ago:"))
                     (org-agenda-scheduled-leaders '("" "%2dd ago:"))
                     (org-super-agenda-groups
                      '((:order 1 :habit t)
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
                         :category "holidays")
                        (:order 5 :log t)))))

            ;; Started
            (org-ql-block '(todo "STRT") ((org-ql-block-header "Started")))

            ;; Next Actions
            (org-ql-block '(and (todo "NEXT") (not (scheduled)))
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
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "%GW%V" "++1w")
                  ,(knopki/org-agenda-command-date-range-opts "This Week" "%a, %d"))

            ;; Next Week
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "%GW%V" "++1w" "++1w")
                  ,(knopki/org-agenda-command-date-range-opts "Next Week" "%a, %d"))))

          ("r" . "Review")
          ("rw" "Week Review"
           (
            ;; prev week
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "%GW%V" "++1w" "--1w")
                  ,(knopki/org-agenda-command-date-range-opts "Previous Week" "%a, %d"))
            ;; this week
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "%GW%V" "++1w")
                  ,(knopki/org-agenda-command-date-range-opts "This Week" "%a, %d"))
            ;; next week
            (tags ,(knopki/org-agenda-tags-limit-dates-macro "%GW%V" "++1w" "++1w")
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
  (org-super-agenda-mode))


;;; Attachments
(after! org-download
  (setq org-download-screenshot-method "grimshot save area %s"))

;;; Expire old entries
(use-package! org-expiry
  :after org
  :commands (org-expiry-insinuate
             org-expiry-deinsinuate
             org-expiry-insert-created
             org-expiry-insert-expiry
             org-expiry-add-keyword
             org-expiry-archive-subtree
             org-expiry-process-entry
             org-expiry-process-entries)
  :custom
  (org-expiry-inactive-timestamps t "Create created/expired timestamps inactive")
  :config
  (org-expiry-insinuate))


(provide 'org-config)
;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; org-config.el ends here
