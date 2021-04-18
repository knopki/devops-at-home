;;; org.el --- Org autoloads -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; CREATED and REVIEWED properties
;;;###autoload
(defun knopki/org-insert-created-at-point (&rest _)
  "Insert CREATED property to the entry at point if not already set."
  (interactive)
  (let* ((prop-name "CREATED")
         (d (org-entry-get (point) prop-name))
         (timestr-active (format-time-string (cdr org-time-stamp-formats)))
         (timestr-inactive (concat "["  (substring timestr-active 1 -1)  "]")))
    (when (null d)
      (save-excursion (org-entry-put (point) prop-name timestr-inactive)))))

;;;###autoload
(defun knopki/org-insert-reviewed-at-point (&rest _)
  "Insert or update REVIEWED property of the entry at point."
  (interactive)
  (let* ((prop-name "REVIEWED")
         (timestr-active (format-time-string (cdr org-time-stamp-formats)))
         (timestr-inactive (concat "[" (substring timestr-active 1 -1) "]")))
    (save-excursion (org-entry-put (point) prop-name timestr-inactive))))

;;;###autoload
(defun knopki/org-insert-created-insinuate ()
  "Add hooks and activate advices for CREATED property."
  (defadvice org-schedule (after org-schedule-update-created)
    (knopki/org-insert-created-at-point))
  (defadvice org-deadline (after org-deadline-update-created)
    (knopki/org-insert-created-at-point))
  (defadvice org-time-stamp (after org-time-stamp-update-created)
    (knopki/org-insert-created-at-point))
  (ad-activate 'org-schedule)
  (ad-activate 'org-time-stamp)
  (ad-activate 'org-deadline)
  (add-hook! '(org-insert-heading-hook
               org-after-todo-state-change-hook
               org-after-tags-change-hook) #'knopki/org-insert-created-at-point))


;;; org-ql queries
;;;; calendar queries
;;;;; weeks
;;;###autoload
(defun knopki/make-weeks-range (TS WEEKS)
  "Create datetime range from first monday before TS and WEEKS long."
  (let* ((start (->> TS
                     (ts-adjust 'day (- (ts-dow (ts-adjust 'day -1 TS))))
                     (ts-apply :hour 0 :minute 0 :second 0)))
         (end (ts-adjust 'day (* 7 WEEKS) 'second -1 start)))
    (cons start end)))

;;;###autoload
(defun knopki/org-ql-week (TITLE BUFFER-FILES DAYS-ADJUST WEEKS)
  "Show items from BUFFER-FILES with TITLE. Start from DAYS-ADJUST from now and WEEKS long."
  (-let* ((ts (ts-adjust 'day DAYS-ADJUST (ts-now)))
          ((beg . end) (knopki/make-weeks-range ts WEEKS))
          (org-super-agenda-date-format "%A, %e %B %Y"))
    (org-ql-search BUFFER-FILES
      `(ts-active :from ,beg :to ,end)
      :title TITLE
      :sort '(date priority todo)
      :super-groups '((:discard (:habit t))
                      (:auto-planning t)))))

;;;###autoload
(defun knopki/org-ql-prev-week ()
  "Show items with an active timestamp during the previous calendar week."
  (interactive)
  (knopki/org-ql-week "Previous Week" (org-agenda-files t t) -7 1))

;;;###autoload
(defun knopki/org-ql-this-week ()
  "Show items with an active timestamp during the this calendar week."
  (interactive)
  (knopki/org-ql-week "Current Week" (org-agenda-files t t) 0 1))

;;;###autoload
(defun knopki/org-ql-next-week ()
  "Show items with an active timestamp during the next calendar week."
  (interactive)
  (knopki/org-ql-week "Next Week" (org-agenda-files) 7 1))

;;;###autoload
(defun knopki/org-ql-3-weeks ()
  "Show items with an active timestamp during the three calendar weeks."
  (interactive)
  (knopki/org-ql-week "Three Weeks" (org-agenda-files t t) -7 3))

;;;;; months
;;;###autoload
(defun knopki/make-months-range (TS MONTHS)
  "Create datetime range from first day of month before TS and MONTHS long."
  (let* ((start (ts-apply :day 1 :hour 0 :minute 0 :second 0 TS))
         (end (ts-adjust 'month MONTHS 'second -1 start)))
    (cons start end)))

;;;###autoload
(defun knopki/org-ql-month (TITLE BUFFER-FILES MONTHS-ADJUST MONTHS)
  "Show items from BUFFER-FILES with TITLE. Start from MONTHS-ADJUST from now and MONTHS long."
  (-let* ((ts (ts-adjust 'month MONTHS-ADJUST (ts-now)))
          ((beg . end) (knopki/make-months-range ts MONTHS))
          (org-super-agenda-date-format "%e %B %Y"))
    (org-ql-search BUFFER-FILES
      `(ts-active :from ,beg :to ,end)
      :title TITLE
      :sort '(date priority todo)
      :super-groups '((:discard (:habit t))
                      (:auto-planning t)))))

;;;###autoload
(defun knopki/org-ql-prev-month ()
  "Show items with an active timestamp during the previous calendar month."
  (interactive)
  (knopki/org-ql-month "Previous Month" (org-agenda-files t t) -1 1))

;;;###autoload
(defun knopki/org-ql-this-month ()
  "Show items with an active timestamp during the current calendar month."
  (interactive)
  (knopki/org-ql-month "Current Month" (org-agenda-files t t) 0 1))

;;;###autoload
(defun knopki/org-ql-next-month ()
  "Show items with an active timestamp during the next calendar month."
  (interactive)
  (knopki/org-ql-month "Next Month" (org-agenda-files) 1 1))

;;;;; years
;;;###autoload
(defun knopki/make-years-range (TS YEARS)
  "Create datetime range from first day of the year before TS and YEARS long."
  (let* ((start (ts-apply :month 0 :day 1 :hour 0 :minute 0 :second 0 TS))
         (end (ts-adjust 'year YEARS 'second -1 start)))
    (cons start end)))

;;;###autoload
(defun knopki/org-ql-year (TITLE BUFFER-FILES YEARS-ADJUST YEARS)
  "Show items from BUFFER-FILES with TITLE. Start from YEARS-ADJUST from now and YEARS long."
  (-let* ((ts (ts-adjust 'year YEARS-ADJUST (ts-now)))
          ((beg . end) (knopki/make-years-range ts YEARS))
          (org-super-agenda-date-format "W%W %B"))
    (org-ql-search BUFFER-FILES
      `(ts-active :from ,beg :to ,end)
      :title TITLE
      :sort '(date priority todo)
      :super-groups '((:discard (:habit t))
                      (:auto-planning t)))))

;;;###autoload
(defun knopki/org-ql-prev-year ()
  "Show items with an active timestamp during the previous calendar year."
  (interactive)
  (knopki/org-ql-year "Previous Year" (org-agenda-files t t) -1 1))

;;;###autoload
(defun knopki/org-ql-this-year ()
  "Show items with an active timestamp during the current calendar year."
  (interactive)
  (knopki/org-ql-month "Current Year" (org-agenda-files t t) 0 1))

;;;###autoload
(defun knopki/org-ql-next-year ()
  "Show items with an active timestamp during the next calendar year."
  (interactive)
  (knopki/org-ql-month "Next Year" (org-agenda-files) 1 1))

;;;; review queries
;;;###autoload
(defun knopki/org-ql-refile ()
  "Open a list of entries for refile."
  (interactive)
  (org-ql-search (org-agenda-files)
    '(and (outline-path "Inbox") (parent))
    :title "Review: Refile"
    :sort '(date)
    :super-groups '((:auto-category t))))

;;;###autoload
(defun knopki/org-ql-stuck-projects ()
  "Open a list of stuck projects."
  (interactive)
  (org-ql-search (org-agenda-files)
    '(and (todo "PROJ")
          (org-entry-blocked-p)
          (descendants (todo))
          (not (descendants (or (scheduled) (deadline auto))))
          (not (descendants (todo "STRT"))))
    :title "Review: Stuck projects"
    :sort '(date)
    :super-groups '((:auto-category t))))

;;;###autoload
(defun knopki/org-ql-stale-tasks ()
  "Open a list of tasks without a timestamp in the past month."
  (interactive)
  (org-ql-search (org-agenda-files)
    '(and (todo)
          (not (ts :from -30))
          (not (descendants)))
    :title "Review: Stale tasks"
    :sort '(date priority todo)
    :super-groups '((:auto-outline-path t))))

;;;###autoload
(defun knopki/org-ql-dangling-tasks ()
  "Open a list of tasks whose ancestor is done."
  (interactive)
  (org-ql-search (org-agenda-files)
    '(and (todo)
          (ancestors (done)))
    :title "Review: Dangling tasks"
    :sort '(date priority todo)
    :super-groups '((:auto-outline-path t))))

;;;###autoload
(defun knopki/org-ql-to-archive ()
  "Open a list of closed but not archived tasks."
  (interactive)
  (org-ql-search (org-agenda-files)
    '(closed :to -30)
    :sort '(scheduled)
    :title "Review: to archive"
    :super-groups '((:auto-outline-path t))))

;;;; other queries
;;;###autoload
(defun knopki/org-ql-quick-tasks ()
  "Open a list of tasks with minimal effort."
  (interactive)
  (org-ql-search (org-agenda-files)
    '(and (todo)
          (property "Effort")
          (not (scheduled))
          (or (not (deadline))
              (deadline auto))
          (>= 30
              (org-duration-to-minutes
               (org-entry-get (point) "Effort"))))
    :title "Quick tasks"
    :sort '(date)
    :super-groups '((:auto-outline-path t))))

;;;###autoload
(defun knopki/org-ql-category-view (CATEGORY)
  "Open an overview of selected project CATEGORY."
  (org-ql-search (org-agenda-files)
    `(and (category ,CATEGORY)
          (todo)
          (not (children)))
    :title (concat "Category " CATEGORY)
    :sort '(date priority todo)
    :super-groups '((:auto-outline-path t))))

;;;###autoload
(defun knopki/org-ql-project-view ()
  "Open an overview of the selected project."
  (interactive)
  (ivy-read "Project: "
            (-distinct
             (org-ql-select (org-agenda-files)
               '(todo)
               :action #'org-get-category))
            :require-match t
            :action #'knopki/org-ql-category-view))

;;;###autoload
(defun knopki/org-ql-waiting ()
  "Open a list of todo items marked with WAIT/HOLD but not scheduled."
  (interactive)
  (org-ql-search (org-agenda-files)
    knopki/org-ql-waiting-query
    :title "Waiting"
    :sort '(date priority todo)
    :super-groups '((:auto-outline-path t))))

;;;###autoload
(defun knopki/org-ql-started ()
  "Open a list of todo items marked with STRT."
  (interactive)
  (org-ql-search (org-agenda-files)
    knopki/org-ql-started-query
    :title "Started"
    :sort '(date priority todo)
    :super-groups '((:auto-outline-path t))))

;;;###autoload
(defun knopki/org-ql-today-agenda ()
  "Open agenda for week."
  (interactive)
  (org-agenda nil "t"))


;;; capture
;;;###autoload
(defun knopki/+org-capture-central-project-file ()
  "Org Capture central project file function."
  (+org--capture-central-file
   (format "%s.pro.org" (projectile-project-name))
   (projectile-project-name)))

;;;###autoload
(defun transform-square-brackets-to-round-ones (STRING)
  "Transforms [ into ( and ] into ) in STRING, other chars left unchanged."
  (concat
   (mapcar #'(lambda (c) (if (equal c ?\[) ?\( (if (equal c ?\]) ?\) c)))
           STRING)))

;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; org.el ends here
