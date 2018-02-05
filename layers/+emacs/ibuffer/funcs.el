;;; funcs.el --- ibuffer Layer functions File for Spacemacs
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Aleksandr Guljajev <gulj.aleks@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defun spacemacs//ibuffer-get-major-modes-ibuff-rules-list (mm-list result-list)
  (if mm-list
      (let* ((cur-mm (car mm-list))
             (next-res-list-el `(,(symbol-name cur-mm) (mode . ,cur-mm))))
        (spacemacs//ibuffer-get-major-modes-ibuff-rules-list
         (cdr mm-list) (cons next-res-list-el result-list)))
    result-list))

(defun spacemacs//ibuffer-get-major-modes-list ()
  (mapcar
   (function (lambda (buffer)
               (buffer-local-value 'major-mode (get-buffer buffer))))
   (buffer-list (selected-frame))))

(defun spacemacs//ibuffer-create-buffs-group ()
  (interactive)
  (let* ((ignore-modes '(Buffer-menu-mode
                         compilation-mode
                         minibuffer-inactive-mode
                         ibuffer-mode
                         magit-process-mode
                         messages-buffer-mode
                         fundamental-mode
                         completion-list-mode
                         help-mode
                         Info-mode))
         (cur-bufs
          (list (cons "Home"
                      (spacemacs//ibuffer-get-major-modes-ibuff-rules-list
                       (cl-set-difference
                        (remove-duplicates
                         (spacemacs//ibuffer-get-major-modes-list))
                        ignore-modes) '())))))
    (setq ibuffer-saved-filter-groups cur-bufs)
    (ibuffer-switch-to-saved-filter-groups "Home")))

(defun memacs//ibuffer-group-by-modes-or-projectile ()
  "Group buffers by modes or projects."
  (cond
   ((eq 'modes ibuffer-group-buffers-by)
    (spacemacs//ibuffer-create-buffs-group))
   ((eq 'projects ibuffer-group-buffers-by)
    (ibuffer-projectile-set-filter-groups)
    (unless (eq ibuffer-sorting-mode 'alphabetic)
      (ibuffer-do-sort-by-alphabetic))))
  )