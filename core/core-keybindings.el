;;; core-keybindings.el --- Spacemacs Core File
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(require 'core-funcs)

(defvar spacemacs/prefix-titles nil
  "alist for mapping command prefixes to long names.")

(defvar spacemacs-default-map (make-sparse-keymap)
  "Base keymap for all spacemacs leader key commands.")

(defvar memacs-search-map (make-sparse-keymap)
  "Search keymap for all text content search commands.")

(defvar memacs-insert-map (make-sparse-keymap)
  "Insert keymap for all text content insert commands.")

(defvar memacs-window-map (make-sparse-keymap)
  "Window keymap for all text content window commands.")

(defvar memacs--search-map-keybinding-prefix "C-s"
  "Keybinding prefix for memacs-search-map.")
(defvar memacs--insert-map-keybinding-prefix "M-i"
  "Keybinding prefix for memacs-insert-map.")
(defvar memacs--window-map-keybinding-prefix "C-w"
  "Keybinding prefix for memacs-window-map")

(global-set-key (kbd memacs--search-map-keybinding-prefix) memacs-search-map)
(global-set-key (kbd memacs--insert-map-keybinding-prefix) memacs-insert-map)

(defun memacs/define-search-keybinding (key def &rest bindings)
  "Binding funcs to search map."
  (while key
    (define-key memacs-search-map (kbd key) def)
    (setq key (pop bindings) def (pop bindings)))
  )

(defun memacs/define-insert-keybinding (key def &rest bindings)
  "Binding funcs to insert map."
  (while key
    (define-key memacs-insert-map (kbd key) def)
    (setq key (pop bindings) def (pop bindings)))
  )

(defun memacs/define-window-keybinding (key def &rest bindings)
  "Binding keys and func for window map"
  (while key
    (define-key memacs-window-map (kbd key) def)
    (setq key (pop bindings) def (pop bindings)))
  )

(defun memacs/define-keys (map key def &rest bindings)
  "Binding funcs to map."
  (while key
    (define-key map (kbd key) def)
    (setq key (pop bindings) def (pop bindings)))
  )

(defun memacs/declare-prefix-for-special-leader-key (leader-key prefix name &optional long-name)
  "Declare a prefix PREFIX. PREFIX is a string describing a key
sequence. NAME is a string used as the prefix command.
LONG-NAME if given is stored in `spacemacs/prefix-titles'."
  (let* ((command name)
         (full-prefix (concat leader-key " " prefix))
         (full-prefix-emacs (concat leader-key " " prefix))
         (full-prefix-lst (listify-key-sequence (kbd full-prefix)))
         (full-prefix-emacs-lst (listify-key-sequence
                                 (kbd full-prefix-emacs))))
    ;; define the prefix command only if it does not already exist
    (unless long-name (setq long-name name))
    (which-key-add-key-based-replacements
      full-prefix-emacs (cons name long-name)
      full-prefix (cons name long-name))))
(put 'memacs/declare-prefix-for-special-leader-key 'lisp-indent-function 'defun)

(defun spacemacs/declare-prefix (prefix name &optional long-name)
  "Declare a prefix PREFIX. PREFIX is a string describing a key
sequence. NAME is a string used as the prefix command.
LONG-NAME if given is stored in `spacemacs/prefix-titles'."
  (let* ((command name)
         (full-prefix (concat dotspacemacs-leader-key " " prefix))
         (full-prefix-emacs (concat dotspacemacs-emacs-leader-key " " prefix))
         (full-prefix-lst (listify-key-sequence (kbd full-prefix)))
         (full-prefix-emacs-lst (listify-key-sequence
                                 (kbd full-prefix-emacs))))
    ;; define the prefix command only if it does not already exist
    (unless long-name (setq long-name name))
    (which-key-add-key-based-replacements
      full-prefix-emacs (cons name long-name)
      full-prefix (cons name long-name))))
(put 'spacemacs/declare-prefix 'lisp-indent-function 'defun)

(defun spacemacs/declare-prefix-for-mode (mode prefix name &optional long-name)
  "Declare a prefix PREFIX. MODE is the mode in which this prefix command should
be added. PREFIX is a string describing a key sequence. NAME is a symbol name
used as the prefix command."
  (let  ((command (intern (concat (symbol-name mode) name)))
         (major-mode-prefix (concat dotspacemacs-major-mode-leader-key
                                    " " prefix))
         (major-mode-prefix-emacs
          (concat dotspacemacs-major-mode-emacs-leader-key
                  " " prefix)))
    (unless long-name (setq long-name name))
    (let ((prefix-name (cons name long-name)))
      (when dotspacemacs-major-mode-leader-key
        (which-key-add-major-mode-key-based-replacements mode major-mode-prefix prefix-name))
      (when dotspacemacs-major-mode-emacs-leader-key
        (which-key-add-major-mode-key-based-replacements
          mode major-mode-prefix-emacs prefix-name)))))
(put 'spacemacs/declare-prefix-for-mode 'lisp-indent-function 'defun)

(defun spacemacs/set-leader-keys (key def &rest bindings)
  "Add KEY and DEF as key bindings under
`dotspacemacs-leader-key' and `dotspacemacs-emacs-leader-key'.
KEY should be a string suitable for passing to `kbd', and it
should not include the leaders. DEF is most likely a quoted
command. See `define-key' for more information about the possible
choices for DEF. This function simply uses `define-key' to add
the bindings.

For convenience, this function will accept additional KEY DEF
pairs. For example,

\(spacemacs/set-leader-keys
   \"a\" 'command1
   \"C-c\" 'command2
   \"bb\" 'command3\)"
  (while key
    (define-key spacemacs-default-map (kbd key) def)
    (setq key (pop bindings) def (pop bindings))))
(put 'spacemacs/set-leader-keys 'lisp-indent-function 'defun)

(defalias 'evil-leader/set-key 'spacemacs/set-leader-keys)

(defun spacemacs//acceptable-leader-p (key)
  "Return t if key is a string and non-empty."
  (and (stringp key) (not (string= key ""))))

(defun spacemacs//init-leader-mode-map (mode map &optional minor)
  "Check for MAP-prefix. If it doesn't exist yet, use `bind-map'
to create it and bind it to `dotspacemacs-major-mode-leader-key'
and `dotspacemacs-major-mode-emacs-leader-key'. If MODE is a
minor-mode, the third argument should be non nil."
  (let* ((prefix (intern (format "%s-prefix" map)))
         (leader (when (spacemacs//acceptable-leader-p
                         dotspacemacs-major-mode-leader-key)
                    dotspacemacs-major-mode-leader-key))
         (emacs-leader (when (spacemacs//acceptable-leader-p
                               dotspacemacs-major-mode-emacs-leader-key)
                          dotspacemacs-major-mode-emacs-leader-key))
         (leaders (delq nil (list leader)))
         (emacs-leaders (delq nil (list emacs-leader))))
    (or (boundp prefix)
        (progn
          (eval
           `(bind-map ,map
              :prefix-cmd ,prefix
              ,(if minor :minor-modes :major-modes) (,mode)
              :keys ,emacs-leaders
              :evil-keys ,leaders
              :evil-states (normal motion visual evilified)))
          (boundp prefix)))))

(defun spacemacs/set-leader-keys-for-major-mode (mode key def &rest bindings)
  "Add KEY and DEF as key bindings under
`dotspacemacs-major-mode-leader-key' and
`dotspacemacs-major-mode-emacs-leader-key' for the major-mode
MODE. MODE should be a quoted symbol corresponding to a valid
major mode. The rest of the arguments are treated exactly like
they are in `spacemacs/set-leader-keys'."
  (let* ((map (intern (format "spacemacs-%s-map" mode))))
    (when (spacemacs//init-leader-mode-map mode map)
      (while key
        (define-key (symbol-value map) (kbd key) def)
        (setq key (pop bindings) def (pop bindings))))))
(put 'spacemacs/set-leader-keys-for-major-mode 'lisp-indent-function 'defun)

(defalias
  'evil-leader/set-key-for-mode
  'spacemacs/set-leader-keys-for-major-mode)

(defun spacemacs/set-leader-keys-for-minor-mode (mode key def &rest bindings)
  "Add KEY and DEF as key bindings under
`dotspacemacs-major-mode-leader-key' and
`dotspacemacs-major-mode-emacs-leader-key' for the minor-mode
MODE. MODE should be a quoted symbol corresponding to a valid
minor mode. The rest of the arguments are treated exactly like
they are in `spacemacs/set-leader-keys'."
  (let* ((map (intern (format "spacemacs-%s-map" mode))))
    (when (spacemacs//init-leader-mode-map mode map t)
      (while key
        (define-key (symbol-value map) (kbd key) def)
        (setq key (pop bindings) def (pop bindings))))))
(put 'spacemacs/set-leader-keys-for-minor-mode 'lisp-indent-function 'defun)

(provide 'core-keybindings)
