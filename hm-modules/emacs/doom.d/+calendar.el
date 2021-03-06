;;; +calendar.el --- Calendar -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

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

;;; Local Variables:
;;; byte-compile-warnings: (not free-vars unresolved)
;;; End:
;;; +calendar.el ends here
