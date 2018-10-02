;;; mp-org/funcs.el --- provide functions for mp-org

;; Author: Mephis Pheies <mephistommm@gmail.com>
;; Keywords: keywords

;;; Commentary:

;; mp-org/create-mrg-buffer provide the fundament for mrg:
;; - create markdown buffer
;; - change current buffer directory

;;; Code:


;;;; Better Default

(defun mp-org/better-default ()
  "Better default for mp-org, something done in
user-config should be defined in this function!"
  ;; (run-with-idle-timer 300 t 'mp-org/auto-org-agenda-task)
  )

(defun memacs//mission-start-candidates-function (str pred _)
  (mapcar (lambda (mission)
            (propertize (car mission) 'property (cdr mission)))
            memacs-mission-starter-mission-list))

(defun memacs/mission-starter-start(mission)
  "Select a mission to start from memacs-mission-start-mission-list."
  (interactive
   (list (completing-read "MISSIONS:"
    #'memacs//mission-start-candidates-function nil t)))
  (let ((mode (nth 0 (get-text-property 0 'property mission)))
        (path (nth 1 (get-text-property 0 'property mission)))
        (file (nth 2 (get-text-property 0 'property mission))))
    (let ((ξbuf (generate-new-buffer mission)))
      (switch-to-buffer ξbuf))
    (call-interactively mode)
    (setq default-directory (if (stringp path) path (eval path)))
    (when (or (stringp file) (listp file))
      (set-visited-file-name (concat
                              default-directory
                              "/"
                              (if (stringp file) file (eval file)))))
    )
  )

(defun memacs//mission-help-candidates-function (str pred _)
  (mapcar (lambda (help)
            (propertize (car help) 'subhelp (cdr help)))
          memacs-mission-helper-help-list))

(defun memacs/mission-helper-help(help)
  "Select a mission to start from memacs-mission-start-mission-list."
  (interactive
   (list (let ((subhelp
                (get-text-property
                 0 'subhelp
                 (completing-read "HELP LIST:"
                                      #'memacs//mission-help-candidates-function
                                      nil t))))
           (completing-read "SUBHELP LIST:"
                                (lambda (str pred _)
                                  (mapcar (lambda (shp)
                                            (propertize
                                             (car shp)
                                             'url (cdr shp)))
                                          subhelp))
                                nil t)
           )))
  (let ((url (nth 0 (get-text-property 0 'url help))))
    (if url
        (browse-url url browse-url-new-window-flag)
      (error "No URL found"))
    )
  )


;;;; Source Code

(defconst mp-org/src-code-types
  '("emacs-lisp" "python" "c" "shell" "java" "js2" "clojure" "c++" "css" "go" "rust" "sh" "sass" "sql" "awk" "haskell" "latex" "lisp" "matlab" "org" "perl" "ruby" "scheme" "sqlite" "yaml"))

(defun mp-org/org-insert-src-code-block (src-code-type)
  "Insert a `SRC-CODE-TYPE' type source code block in org-mode.
Go files should disable fly-check."
  (interactive (list (completing-read "Source code type: " mp-org/src-code-types)))
  (progn
    (newline-and-indent)
    (insert (format "#+BEGIN_SRC %s\n" src-code-type))
    (newline-and-indent)
    (insert "#+END_SRC\n")
    (previous-line 2)
    (org-edit-src-code)))

(defun mp-org/wrap-math-block-formula (start end)
  "Insert '\\[ ... \\]' to the begin and end of formula"
  (interactive "r")
  (save-excursion
    (narrow-to-region start end)
    (goto-char (point-min))
    (insert "\\[ ")
    (goto-char (point-max))
    (insert " \\]")
    (widen))
  )

(defun mp-org/wrap-math-inline-formula (start end)
  "Insert '\\( ... \\)' or '\\[ ... \\]' to the begin and end of formula"
  (interactive "r")
  (save-excursion
    (narrow-to-region start end)
    (goto-char (point-min))
    (insert "\\( ")
    (goto-char (point-max))
    (insert " \\)")
    (widen))
  )

(defun mp-org/wrap-source-code (start end)
  "Insert '#+BEGIN_SRC lang' and '#+END_SRC' to the begin and end of code"
  (interactive "r")
  (let ((lang (completing-read "Source code type: " mp-org/src-code-types)))
    (save-excursion
      (narrow-to-region start end)
      (goto-char (point-min))
      (insert (format "#+BEGIN_SRC %s\n" lang))
      (goto-char (point-max))
      (insert "#+END_SRC\n")
      (widen))
    )
  )

(defun mp-org/wrap-unordered-list (start end)
  "Insert '- ' to the begin of each line."
  (interactive "r")
  (save-excursion
    (narrow-to-region start end)
    (goto-char (point-max))
    (while (> (forward-line -1) -1) (insert "- "))
    (widen))
  )

(defun mp-org/wrap-ordered-list (start end)
  "Insert '%d. ' to the begin of each line."
  (interactive "r")
  (save-excursion
    (narrow-to-region start end)
    (goto-char (point-min))
    (let* ((lineno 1)
          (linecount (count-lines start end)))
      (while (<= lineno linecount)
        (insert (format "%d. " lineno))
        (forward-line 1)
        (setq lineno (1+ lineno))))
    (widen))
  )

(defun mp-org/wrap-quote (start end)
  "Insert '#+BEGIN_QUOTE' and '#+END_QUOTE' to the begin and end of quote region"
  (interactive "r")
  (save-excursion
    (narrow-to-region start end)
    (goto-char (point-min))
    (insert "#+BEGIN_QUOTE\n")
    (goto-char (point-max))
    (insert "#+END_QUOTE\n")
    (widen))
  )

(defun mp-org/wrap-link (start end)
  "Insert '[' , ']' and link string to the begin and end of region."
  (interactive "r")
  (let ((link (completing-read "Value of link: " (mp-org//link-switch))))
    (save-excursion
      (narrow-to-region start end)
      (goto-char (point-min))
      (insert (format "[[%s][" link))
      (goto-char (point-max))
      (insert "]]")
      (widen)))
  )

(defun mp-org//linkp (linkstr)
  "Test for link line."
  (string-match "^\\(http\\|file\\|https\\|img\\):" (substring-no-properties linkstr)))

(defun mp-org//link-switch ()
  "Filter link lines in counsel kills, if used ivy layer,
otherwise in kill-rang."
  (if (configuration-layer/layer-usedp 'ivy)
      (seq-filter 'mp-org//linkp (counsel--yank-pop-kills))
      (seq-filter 'mp-org//linkp kill-ring))
  )


;;;; Auto Org Agenda

(defun mp-org/org-agenda-reload-files ()
  "Reset the default value of org-agenda-reload-files."
  (interactive)
  (setq-default org-agenda-files (find-lisp-find-files org-directory "\.org$"))
  (message "Reload org files success!")
  )

(defun mp-org/auto-org-agenda-task ()
  "If auto org agenda task is not close.
Switch to @org -> reload org agenda file -> show agenda list"
  (unless close-auto-org-agenda-task
    (spacemacs/custom-perspective-@Org)
    (mp-org/org-agenda-reload-files)
    (org-agenda-list))
  )

(defun mp-org/switch-auto-org-agenda-task ()
  (interactive)
  (setq close-auto-org-agenda-task (not close-auto-org-agenda-task))
  (if close-auto-org-agenda-task
      (message "Closed auto org agenda task.")
      (message "Opened auto org agenda task."))
  )


;;; mp-org/funcs.el ends here
