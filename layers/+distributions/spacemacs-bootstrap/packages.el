;;; packages.el --- Mandatory Bootstrap Layer packages File
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq spacemacs-bootstrap-packages
      '(
        ;; bootstrap packages,
        ;; `use-package' cannot be used for bootstrap packages configuration
        (async :step bootstrap)
        (bind-map :step bootstrap)
        (bind-key :step bootstrap)
        (diminish :step bootstrap)
        (evil :step bootstrap)
        (hydra :step bootstrap)
        (use-package :step bootstrap)
        (which-key :step bootstrap)
        (websocket :step bootstrap)
        ;; pre packages, initialized aftert the bootstrap packages
        ;; these packages can use use-package
        (dotenv-mode :step pre)
        (evil-evilified-state :location local :step pre :protected t)
        (pcre2el :step pre)
        (hybrid-mode :location local :step pre)
        (spacemacs-theme :location built-in)
        ))


;; bootstrap packages

(defun spacemacs-bootstrap/init-async ())

(defun spacemacs-bootstrap/init-bind-key ())

(defun spacemacs-bootstrap/init-diminish ()
  (when (not (configuration-layer/package-used-p 'spaceline))
    (add-hook 'after-load-functions 'spacemacs/diminish-hook)))

(defun spacemacs-bootstrap/init-dotenv-mode ()
  (use-package dotenv-mode
    :defer t))

(defun spacemacs-bootstrap/init-bind-map ()
  (require 'bind-map)
  (bind-map spacemacs-default-map
    :prefix-cmd spacemacs-cmds
    :keys (dotspacemacs-emacs-leader-key)
    :evil-keys (dotspacemacs-leader-key)
    :override-minor-modes t
    :override-mode-name spacemacs-leader-override-mode))

(defun spacemacs-bootstrap/init-evil ()
  ;; ensure that the search module is set at startup
  ;; must be called before evil is required to really take effect.
  (setq-default evil-search-module 'evil-search)

  ;; evil-mode is mandatory for Spacemacs to work properly
  ;; evil must be require explicitly, the autoload seems to not
  ;; work properly sometimes.
  (require 'evil)
  (evil-mode 1)
  (setq-default memacs-window-map evil-window-map)

  ;; Use evil as a default jump handler
  (add-to-list 'spacemacs-default-jump-handlers 'evil-goto-definition)

  (require 'cl)
  ;; State cursors
  (cl-loop for (state color shape) in spacemacs-evil-cursors
           do (spacemacs/add-evil-cursor state color shape))
  (add-hook 'spacemacs-post-theme-change-hook 'spacemacs/set-state-faces)

  ;; evil ex-command
  (define-key evil-normal-state-map (kbd dotspacemacs-ex-command-key) 'evil-ex)
  (define-key evil-visual-state-map (kbd dotspacemacs-ex-command-key) 'evil-ex)
  (define-key evil-motion-state-map (kbd dotspacemacs-ex-command-key) 'evil-ex)
  (setq evil-ex-substitute-global vim-style-ex-substitute-global)

  ;; evil-want-Y-yank-to-eol must be set via customize to have an effect
  (customize-set-variable 'evil-want-Y-yank-to-eol vim-style-remap-Y-to-y$)

  ;; Make the current definition and/or comment visible.
  (define-key evil-normal-state-map "zf" 'reposition-window)
  ;; toggle maximize buffer
  (define-key evil-window-map (kbd "o") 'spacemacs/toggle-maximize-buffer)

  ;; motions keys for help buffers
  (evil-define-key 'motion help-mode-map (kbd "<escape>") 'quit-window)
  (evil-define-key 'motion help-mode-map (kbd "<tab>") 'forward-button)
  (evil-define-key 'motion help-mode-map (kbd "S-<tab>") 'backward-button)
  (evil-define-key 'motion help-mode-map (kbd "]") 'help-go-forward)
  (evil-define-key 'motion help-mode-map (kbd "gf") 'help-go-forward)
  (evil-define-key 'motion help-mode-map (kbd "[") 'help-go-back)
  (evil-define-key 'motion help-mode-map (kbd "gb") 'help-go-back)
  (evil-define-key 'motion help-mode-map (kbd "gh") 'help-follow-symbol)

  ;; It's better that the default value is too small than too big
  (setq-default evil-shift-width 2)
  ;; After major mode has changed, reset evil-shift-width
  (add-hook 'after-change-major-mode-hook 'spacemacs//set-evil-shift-width 'append)

  ;; Keep the region active when shifting
  (when vim-style-retain-visual-state-on-shift
    (evil-map visual "<" "<gv")
    (evil-map visual ">" ">gv"))

  ;; move selection up and down
  (when vim-style-visual-line-move-text
    (define-key evil-visual-state-map "J" (concat ":m '>+1" (kbd "RET") "gv=gv"))
    (define-key evil-visual-state-map "K" (concat ":m '<-2" (kbd "RET") "gv=gv")))

  (evil-ex-define-cmd "enew" 'spacemacs/new-empty-buffer)

  (define-key evil-normal-state-map (kbd "K") 'spacemacs/evil-smart-doc-lookup)
  (define-key evil-normal-state-map (kbd "gd") 'spacemacs/jump-to-definition)
  (define-key evil-normal-state-map (kbd "gD") 'spacemacs/jump-to-definition-other-window)

  ;; scrolling transient state
  (spacemacs|define-transient-state scroll
    :title "Scrolling Transient State"
    :doc "
 Line/Column^^^^      Half Page^^^^        Full Page^^ Buffer^^^^    Other
 ───────────^^^^───── ─────────^^^^─────── ─────────^^ ──────^^^^─── ─────^^───
 [_k_]^^   up         [_u_/_K_] up         [_b_] up    [_<_/_g_] beg [_q_] quit
 [_j_]^^   down       [_d_/_J_] down       [_f_] down  [_>_/_G_] end
 [_h_/_l_] left/right [_H_/_L_] left/right"
    :bindings
    ;; lines and columns
    ("j" evil-scroll-line-down)
    ("k" evil-scroll-line-up)
    ("h" evil-scroll-column-left)
    ("l" evil-scroll-column-right)
    ;; half page
    ("d" evil-scroll-down)
    ("u" evil-scroll-up)
    ("J" evil-scroll-down)
    ("K" evil-scroll-up)
    ("H" evil-scroll-left)
    ("L" evil-scroll-right)
    ;; full page
    ("f" evil-scroll-page-down)
    ("b" evil-scroll-page-up)
    ;; buffer
    ("<" evil-goto-first-line)
    (">" evil-goto-line)
    ("g" evil-goto-first-line)
    ("G" evil-goto-line)
    ;; other
    ("q" nil :exit t))
  (spacemacs/set-leader-keys
    ;; lines and columns
    "Nj" 'spacemacs/scroll-transient-state/evil-scroll-line-down
    "Nk" 'spacemacs/scroll-transient-state/evil-scroll-line-up
    "Nh" 'spacemacs/scroll-transient-state/evil-scroll-column-left
    "Nl" 'spacemacs/scroll-transient-state/evil-scroll-column-right
    ;; half page
    "Nd" 'spacemacs/scroll-transient-state/evil-scroll-down
    "Nu" 'spacemacs/scroll-transient-state/evil-scroll-up
    "NJ" 'spacemacs/scroll-transient-state/evil-scroll-down
    "NK" 'spacemacs/scroll-transient-state/evil-scroll-up
    "NH" 'spacemacs/scroll-transient-state/evil-scroll-left
    "NL" 'spacemacs/scroll-transient-state/evil-scroll-right
    ;; full page
    "Nf" 'spacemacs/scroll-transient-state/evil-scroll-page-down
    "Nb" 'spacemacs/scroll-transient-state/evil-scroll-page-up
    ;; buffer
    "N<" 'spacemacs/scroll-transient-state/evil-goto-first-line
    "N>" 'spacemacs/scroll-transient-state/evil-goto-line
    "Ng" 'spacemacs/scroll-transient-state/evil-goto-first-line
    "NG" 'spacemacs/scroll-transient-state/evil-goto-line)

  ;; fold transient state
  (when (eq 'evil dotspacemacs-folding-method)
    (spacemacs|define-transient-state fold
      :title "Code Fold Transient State"
      :doc "
 Close^^          Open^^              Toggle^^             Other^^
 ───────^^──────  ─────^^───────────  ─────^^────────────  ─────^^───
 [_c_] at point   [_o_] at point      [_a_] around point   [_q_] quit
 ^^               [_O_] recursively   ^^
 [_m_] all        [_r_] all"
      :foreign-keys run
      :bindings
      ("a" evil-toggle-fold)
      ("c" evil-close-fold)
      ("o" evil-open-fold)
      ("O" evil-open-fold-rec)
      ("r" evil-open-folds)
      ("m" evil-close-folds)
      ("q" nil :exit t)
      ("C-g" nil :exit t)
      ("<SPC>" nil :exit t)))
  (memacs/define-evil-normal-keybinding "z." 'spacemacs/fold-transient-state/body)

  ;; define text objects
  (spacemacs|define-text-object "$" "dollar" "$" "$")
  (spacemacs|define-text-object "*" "star" "*" "*")
  (spacemacs|define-text-object "8" "block-star" "/*" "*/")
  (spacemacs|define-text-object "|" "bar" "|" "|")
  (spacemacs|define-text-object "%" "percent" "%" "%")
  (spacemacs|define-text-object "/" "slash" "/" "/")
  (spacemacs|define-text-object "_" "underscore" "_" "_")
  (spacemacs|define-text-object "-" "hyphen" "-" "-")
  (spacemacs|define-text-object "~" "tilde" "~" "~")
  (spacemacs|define-text-object "=" "equal" "=" "=")
  (spacemacs|define-text-object "«" "double-angle-bracket" "«" "»")
  (spacemacs|define-text-object "｢" "corner-bracket" "｢" "｣")
  (spacemacs|define-text-object "‘" "single-quotation-mark" "‘" "’")
  (spacemacs|define-text-object "“" "double-quotation-mark" "“" "”")
  (evil-define-text-object evil-pasted (count &rest args)
    (list (save-excursion (evil-goto-mark ?\[) (point))
          (save-excursion (evil-goto-mark ?\]) (1+ (point)))))
  (define-key evil-inner-text-objects-map "P" 'evil-pasted)
  ;; define text-object for entire buffer
  (evil-define-text-object evil-inner-buffer (count &optional beg end type)
    (list (point-min) (point-max)))
  (define-key evil-inner-text-objects-map "g" 'evil-inner-buffer)

  ;; turn off evil in corelv buffers
  (add-to-list 'evil-buffer-regexps '("\\*LV\\*"))

  (with-eval-after-load 'dired
    (evil-define-key 'normal dired-mode-map "J" 'counsel-find-file)
    (define-key dired-mode-map "j" 'counsel-find-file)
    (evil-define-key 'normal dired-mode-map (kbd dotspacemacs-leader-key)
      spacemacs-default-map))

  ;; Define history commands for comint
  (evil-define-key 'normal comint-mode-map
    (kbd "C-p") 'comint-previous-input
    (kbd "C-n") 'comint-next-input)

  ;; ignore repeat
  (evil-declare-ignore-repeat 'spacemacs/next-error)
  (evil-declare-ignore-repeat 'spacemacs/previous-error))

(defun spacemacs-bootstrap/init-hydra ()
  (require 'hydra)
  (setq hydra-key-doc-function 'spacemacs//hydra-key-doc-function
        hydra-head-format "[%s] "))

(defun spacemacs-bootstrap/init-use-package ()
  (require 'use-package)
  (setq use-package-verbose init-file-debug
        ;; inject use-package hooks for easy customization of stock package
        ;; configuration
        use-package-inject-hooks t))

(defun spacemacs-bootstrap/init-which-key ()
  (require 'which-key)

  (setq which-key-special-keys nil
        which-key-use-C-h-for-paging t
        which-key-prevent-C-h-from-cycling t
        which-key-echo-keystrokes 0.02
        which-key-max-description-length 32
        which-key-allow-multiple-replacements t
        which-key-sort-order 'which-key-key-order-alpha
        which-key-idle-delay dotspacemacs-which-key-delay
        which-key-idle-secondary-delay 0.01
        which-key-allow-evil-operators t)

  (spacemacs|add-toggle which-key
    :mode which-key-mode
    :documentation
    "Display a buffer with available key bindings."
    :evil-leader "tK")

  (spacemacs/set-leader-keys "hk" 'which-key-show-top-level)

  ;; Needed to avoid nil variable error before update to recent which-key
  (defvar which-key-replacement-alist nil)
  ;; Reset to the default or customized value before adding our values in order
  ;; to make this initialization code idempotent.
  (custom-reevaluate-setting 'which-key-replacement-alist)
  ;; Replace rules for better naming of functions
  (let ((new-descriptions
         ;; being higher in this list means the replacement is applied later
         '(
           ("spacemacs/\\(.+\\)" . "\\1")
           ("spacemacs-\\(.+\\)" . "\\1")
           ("spacemacs/toggle-\\(.+\\)" . "\\1")
           ("\\(.+\\)-transient-state/\\(.+\\)" . "\\2")
           ("\\(.+\\)-transient-state/body" . "\\1-transient-state")
           ("spacemacs/alternate-buffer" . "last buffer")
           ("spacemacs/toggle-mode-line-\\(.+\\)" . "\\1")
           ("avy-goto-word-or-subword-1" . "avy word")
           ("shell-command" . "shell cmd")
           ("spacemacs/default-pop-shell" . "open shell")
           ("spacemacs/search-project-auto-region-or-symbol" . "search project w/input")
           ("spacemacs/search-project-auto" . "search project")
           ("sp-split-sexp" . "split sexp")
           ("avy-goto-line" . "avy line")
           ("er/expand-region" . "expand region")
           ("evil-lisp-state-\\(.+\\)" . "\\1")
           ("universal-argument" . "universal arg")
           ("ivy-switch-buffer" . "list-buffers")
           ("spacemacs-layouts/non-restricted-buffer-list-ivy" . "global-list-buffers"))))
    (dolist (nd new-descriptions)
      ;; ensure the target matches the whole string
      (push (cons (cons nil (concat "\\`" (car nd) "\\'")) (cons nil (cdr nd)))
            which-key-replacement-alist)))

  ;; Group together sequence and identical key entries in the which-key popup
  ;; SPC h k- Top-level bindings
  ;; Remove spaces around the two dots ".."
  (push '(("\\(.*\\)1 .. 9" . "digit-argument") .
          ("\\11..9" . "digit-argument"))
        which-key-replacement-alist)

  ;; And remove the modifier key(s) before the last nr in the sequence
  (push '(("\\(.*\\)C-0 .. C-5" . "digit-argument") .
          ("\\1C-0..5" . "digit-argument"))
        which-key-replacement-alist)

  (push '(("\\(.*\\)C-7 .. C-9" . "digit-argument") .
          ("\\1C-7..9" . "digit-argument"))
        which-key-replacement-alist)

  (push '(("\\(.*\\)C-M-0 .. C-M-9" . "digit-argument") .
          ("\\1C-M-0..9" . "digit-argument"))
        which-key-replacement-alist)

  ;; SPC k- lisp
  ;; rename "1 .. 9 -> digit-argument" to "1..9 -> digit-argument"
  (push '(("\\(.*\\)1 .. 9" . "evil-lisp-state-digit-argument") .
          ("\\11..9" . "digit-argument"))
        which-key-replacement-alist)

  ;; SPC n- narrow/numbers
  ;; Combine + and =
  (push '(("\\(.*\\)+" . "evil-numbers/inc-at-pt") .
          ("\\1+,=" . "evil-numbers/inc-at-pt"))
        which-key-replacement-alist)

  ;; hide "= -> evil-numbers/inc-at-pt" entry
  (push '(("\\(.*\\)=" . "evil-numbers/inc-at-pt") . t)
        which-key-replacement-alist)

  ;; Combine - and _
  (push '(("\\(.*\\)-" . "evil-numbers/dec-at-pt") .
          ("\\1-,_" . "evil-numbers/dec-at-pt"))
        which-key-replacement-alist)

  ;; hide "_ -> evil-numbers/dec-at-pt" entry
  (push '(("\\(.*\\)_" . "evil-numbers/dec-at-pt") . t)
        which-key-replacement-alist)

  ;; SPC x i- inflection
  ;; rename "k -> string-inflection-kebab-case"
  ;; to "k,- -> string-inflection-kebab-case"
  (push '(("\\(.*\\)k" . "string-inflection-kebab-case") .
          ("\\1k,-" . "string-inflection-kebab-case"))
        which-key-replacement-alist)

  ;; hide the "- -> string-inflection-kebab-case" entry
  (push '(("\\(.*\\)-" . "string-inflection-kebab-case") . t)
        which-key-replacement-alist)

  ;; rename "u -> string-inflection-underscore"
  ;; to "u,_ -> string-inflection-underscore"
  (push '(("\\(.*\\)u" . "string-inflection-underscore") .
          ("\\1u,_" . "string-inflection-underscore"))
        which-key-replacement-alist)

  ;; hide the "_ -> string-inflection-underscore" entry
  (push '(("\\(.*\\)_" . "string-inflection-underscore") . t)
        which-key-replacement-alist)

  ;; C-c C-w-
  ;; rename the eyebrowse-switch-to-window-config-0 entry, to 0..9
  (push '(("\\(.*\\)0" . "eyebrowse-switch-to-window-config-0") .
          ("\\10..9" . "eyebrowse-switch-to-window-config-0..9"))
        which-key-replacement-alist)

  ;; hide the "[1-9] -> eyebrowse-switch-to-window-config-[1-9]" entries
  (push '((nil . "eyebrowse-switch-to-window-config-[1-9]") . t)
        which-key-replacement-alist)

  ;; Combine the c and C-c key entries
  (push '(("\\(.*\\)C-c C-w c" . "eyebrowse-create-window-config") .
          ("\\1c,C-c" . "eyebrowse-create-window-config"))
        which-key-replacement-alist)

  ;; hide the "C-c -> eyebrowse-create-window-config" entry
  (push '(("\\(.*\\)C-c C-w C-c" . "eyebrowse-create-window-config") . t)
        which-key-replacement-alist)

  ;; C-c C-d-
  ;; Combine the d and C-d key entries
  (push '(("\\(.*\\)C-c C-d d" . "elisp-slime-nav-describe-elisp-thing-at-point") .
          ("\\1d,C-d" . "elisp-slime-nav-describe-elisp-thing-at-point"))
        which-key-replacement-alist)

  ;; hide the "C-d -> elisp-slime-nav-describe-elisp-thing-at-point" entry
  (push '(("\\(.*\\)C-c C-d C-d" . "elisp-slime-nav-describe-elisp-thing-at-point") . t)
        which-key-replacement-alist)

  (which-key-add-key-based-replacements
    dotspacemacs-leader-key '("root" . "Spacemacs root")
    dotspacemacs-emacs-leader-key '("root" . "Spacemacs root"))

  ;; disable special key handling for spacemacs, since it can be
  ;; disorienting if you don't understand it
  (pcase dotspacemacs-which-key-position
    (`right (which-key-setup-side-window-right))
    (`bottom (which-key-setup-side-window-bottom))
    (`right-then-bottom (which-key-setup-side-window-right-bottom)))

  (which-key-mode)
  (spacemacs|diminish which-key-mode " Ⓚ" " K"))

;; pre packages

(defun spacemacs-bootstrap/init-evil-evilified-state ()
  (use-package evil-evilified-state)
  (define-key evil-evilified-state-map (kbd dotspacemacs-leader-key)
    spacemacs-default-map))

;; we own pcre2el here, so that it's always available to ivy and helm
;; (necessary when using spacemacs-base distribution)
(defun spacemacs-bootstrap/init-pcre2el ()
  (use-package pcre2el :defer t))

(defun spacemacs-bootstrap/init-hybrid-mode ()
  (spacemacs|unless-dumping-and-eval-after-loaded-dump
   holy-mode
   (use-package hybrid-mode
     :config
     (progn
       (hybrid-mode)
       (setq hybrid-mode-default-state 'normal
             hybrid-mode-enable-evilified-state t)
       (spacemacs|diminish hybrid-mode)))))

(defun spacemacs-bootstrap/init-spacemacs-theme ()
  (use-package spacemacs-theme
    :init (setq spacemacs-theme-keyword-italic t
                spacemacs-theme-comment-bg t
                spacemacs-theme-org-height t)))

(defun spacemacs-bootstrap/init-websocket())
