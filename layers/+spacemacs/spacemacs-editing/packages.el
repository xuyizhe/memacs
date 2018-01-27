;;; packages.el --- Spacemacs Editing Layer packages File
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq spacemacs-editing-packages
      '(avy
        clean-aindent-mode
        editorconfig
        eval-sexp-fu
        expand-region
        (hexl :location built-in)
        link-hint
        lorem-ipsum
        move-text
        (origami :toggle (eq 'origami dotspacemacs-folding-method))
        password-generator
        (spacemacs-whitespace-cleanup :location local)
        string-inflection
        undo-tree
        uuidgen
        ws-butler))

;; Initialization of packages

(defun spacemacs-editing/init-avy ()
  (use-package avy
    :defer t
    :commands (spacemacs/avy-open-url spacemacs/avy-goto-url avy-pop-mark)
    :init
    (progn
      (setq avy-all-windows 'all-frames)
      (setq avy-background t)
      (memacs/define-evil-keybinding
       (list
        evil-normal-state-map
        evil-motion-state-map
        evil-hybrid-state-map
        evil-visual-state-map)
       "C-j r"   'avy-resume
       "C-j b"   'avy-pop-mark
       "C-j c"   'evil-avy-goto-char
       "C-j C"   'evil-avy-goto-char-2
       "C-j l"   'evil-avy-goto-line
       "C-l"     'evil-avy-goto-line
       "C-j u"   'spacemacs/avy-goto-url
       "C-j C-u" 'spacemacs/avy-open-url
       "C-j w"   'evil-avy-goto-word-or-subword-1
       "C-j W"   'evil-avy-goto-word-0
       "C-j j"   'evil-avy-goto-char-timer))
    :config
    (progn
      (defun spacemacs/avy-goto-url()
        "Use avy to go to an URL in the buffer."
        (interactive)
        (avy--generic-jump "https?://" nil 'pre))
      (defun spacemacs/avy-open-url ()
        "Use avy to select an URL in the buffer and open it."
        (interactive)
        (save-excursion
          (spacemacs/avy-goto-url)
          (browse-url-at-point))))))

(defun spacemacs-editing/init-clean-aindent-mode ()
  (use-package clean-aindent-mode
    :config (clean-aindent-mode)))

(defun spacemacs-editing/init-editorconfig ()
  (use-package editorconfig
    :init
    (spacemacs|diminish editorconfig-mode)
    :config
    (editorconfig-mode t)))

(defun spacemacs-editing/init-eval-sexp-fu ()
  ;; ignore obsolete function warning generated on startup
  (let ((byte-compile-not-obsolete-funcs (append byte-compile-not-obsolete-funcs '(preceding-sexp))))
    (require 'eval-sexp-fu)))

(defun spacemacs-editing/init-expand-region ()
  (use-package expand-region
    :defer t
    :init (spacemacs/set-leader-keys "v" 'er/expand-region)
    :config
    (progn
      ;; add search capability to expand-region
      (setq expand-region-contract-fast-key "V"
            expand-region-reset-fast-key "r"))))

(defun spacemacs-editing/init-hexl ()
  (use-package hexl
    :defer t
    :init
    (progn
      (spacemacs/set-leader-keys "fh" 'hexl-find-file)
      (spacemacs/set-leader-keys-for-major-mode 'hexl-mode
        "d" 'hexl-insert-decimal-char
        "c" 'hexl-insert-octal-char
        "x" 'hexl-insert-hex-char
        "X" 'hexl-insert-hex-string
        "g" 'hexl-goto-address)
      (evil-define-key 'motion hexl-mode-map
        "]]" 'hexl-end-of-1k-page
        "[[" 'hexl-beginning-of-1k-page
        "h" 'hexl-backward-char
        "l" 'hexl-forward-char
        "j" 'hexl-next-line
        "k" 'hexl-previous-line
        "$" 'hexl-end-of-line
        "^" 'hexl-beginning-of-line
        "0" 'hexl-beginning-of-line))))

(defun spacemacs-editing/init-link-hint ()
  (use-package link-hint
    :defer t
    :init
    (spacemacs/set-leader-keys
      "xo" 'link-hint-open-link
      "xO" 'link-hint-open-multiple-links)))

(defun spacemacs-editing/init-lorem-ipsum ()
  (use-package lorem-ipsum
    :commands (lorem-ipsum-insert-list
               lorem-ipsum-insert-paragraphs
               lorem-ipsum-insert-sentences)
    :init
    (progn
      (spacemacs/declare-prefix "il" "lorem ipsum")
      (spacemacs/set-leader-keys
        "ill" 'lorem-ipsum-insert-list
        "ilp" 'lorem-ipsum-insert-paragraphs
        "ils" 'lorem-ipsum-insert-sentences))))

(defun spacemacs-editing/init-move-text ()
  (use-package move-text
    :defer t
    :init
    (spacemacs|define-transient-state move-text
      :title "Move Text Transient State"
      :bindings
      ("J" move-text-down "move down")
      ("K" move-text-up "move up"))
    (spacemacs/set-leader-keys
      "xJ" 'spacemacs/move-text-transient-state/move-text-down
      "xK" 'spacemacs/move-text-transient-state/move-text-up)))

(defun spacemacs-editing/init-origami ()
  (use-package origami
    :defer t
    :init
    (progn
      (global-origami-mode)
      (define-key evil-normal-state-map "za" 'origami-forward-toggle-node)
      (define-key evil-normal-state-map "zc" 'origami-close-node)
      (define-key evil-normal-state-map "zC" 'origami-close-node-recursively)
      (define-key evil-normal-state-map "zO" 'origami-open-node-recursively)
      (define-key evil-normal-state-map "zo" 'origami-open-node)
      (define-key evil-normal-state-map "zr" 'origami-open-all-nodes)
      (define-key evil-normal-state-map "zm" 'origami-close-all-nodes)
      (define-key evil-normal-state-map "zs" 'origami-show-only-node)
      (define-key evil-normal-state-map "zn" 'origami-next-fold)
      (define-key evil-normal-state-map "zp" 'origami-previous-fold)
      (define-key evil-normal-state-map "zR" 'origami-reset)
      (define-key evil-normal-state-map (kbd "z <tab>") 'origami-recursively-toggle-node)
      (define-key evil-normal-state-map (kbd "z TAB") 'origami-recursively-toggle-node)

      (spacemacs|define-transient-state fold
        :title "Code Fold Transient State"
        :doc "
 Close^^            Open^^             Toggle^^         Goto^^         Other^^
 ───────^^───────── ─────^^─────────── ─────^^───────── ──────^^────── ─────^^─────────
 [_c_] at point     [_o_] at point     [_a_] at point   [_n_] next     [_s_] single out
 [_C_] recursively  [_O_] recursively  [_A_] all        [_p_] previous [_R_] reset
 [_m_] all          [_r_] all          [_TAB_] like org ^^             [_q_] quit"
        :foreign-keys run
        :on-enter (unless (bound-and-true-p origami-mode) (origami-mode 1))
        :bindings
        ("a" origami-forward-toggle-node)
        ("A" origami-toggle-all-nodes)
        ("c" origami-close-node)
        ("C" origami-close-node-recursively)
        ("o" origami-open-node)
        ("O" origami-open-node-recursively)
        ("r" origami-open-all-nodes)
        ("m" origami-close-all-nodes)
        ("n" origami-next-fold)
        ("p" origami-previous-fold)
        ("s" origami-show-only-node)
        ("R" origami-reset)
        ("TAB" origami-recursively-toggle-node)
        ("<tab>" origami-recursively-toggle-node)
        ("q" nil :exit t)
        ("C-g" nil :exit t)
        ("<SPC>" nil :exit t))
      ;; Note: The key binding for the fold transient state is defined in
      ;; evil config
      )))

(defun spacemacs-editing/init-password-generator ()
  (use-package password-generator
    :defer t
    :init
    (progn
      (spacemacs/declare-prefix "ip" "passwords")
      (evil-leader/set-key
        "ip1" 'password-generator-simple
        "ip2" 'password-generator-strong
        "ip3" 'password-generator-paranoid
        "ipp" 'password-generator-phonetic
        "ipn" 'password-generator-numeric))))

(defun spacemacs-editing/init-spacemacs-whitespace-cleanup ()
  (use-package spacemacs-whitespace-cleanup
    :commands (spacemacs-whitespace-cleanup-mode
               global-spacemacs-whitespace-cleanup-mode)
    :init
    (progn
      (spacemacs|add-toggle whitespace-cleanup
        :mode spacemacs-whitespace-cleanup-mode
        :documentation "Automatic whitespace clean up."
        :on-message (spacemacs-whitespace-cleanup/on-message)
        :evil-leader "tW")
      (spacemacs|add-toggle global-whitespace-cleanup
        :mode global-spacemacs-whitespace-cleanup-mode
        :status spacemacs-whitespace-cleanup-mode
        :on (let ((spacemacs-whitespace-cleanup-globally t))
              (spacemacs-whitespace-cleanup-mode))
        :off (let ((spacemacs-whitespace-cleanup-globally t))
               (spacemacs-whitespace-cleanup-mode -1))
        :on-message (spacemacs-whitespace-cleanup/on-message t)
        :documentation "Global automatic whitespace clean up."
        :evil-leader "t C-S-w")
      (with-eval-after-load 'ws-butler
        (when dotspacemacs-whitespace-cleanup
          (spacemacs/toggle-global-whitespace-cleanup-on))))
    :config
    (progn
      (spacemacs|diminish spacemacs-whitespace-cleanup-mode " Ⓦ" " W")
      (spacemacs|diminish global-spacemacs-whitespace-cleanup-mode
                          " Ⓦ" " W"))))

(defun spacemacs-editing/init-string-inflection ()
  (use-package string-inflection
    :init
    (progn
      (spacemacs|define-transient-state string-inflection
        :title "String Inflection Transient State"
        :doc "\n [_i_] cycle"
        :bindings
        ("i" string-inflection-all-cycle))
      (spacemacs/declare-prefix "xi" "inflection")
      (spacemacs/set-leader-keys
        "xic" 'string-inflection-lower-camelcase
        "xiC" 'string-inflection-camelcase
        "xii" 'spacemacs/string-inflection-transient-state/body
        "xi-" 'string-inflection-kebab-case
        "xik" 'string-inflection-kebab-case
        "xi_" 'string-inflection-underscore
        "xiu" 'string-inflection-underscore
        "xiU" 'string-inflection-upcase))))

(defun spacemacs-editing/init-undo-tree ()
  (use-package undo-tree
    :init
    (progn
      (global-undo-tree-mode)
      (setq undo-tree-visualizer-timestamps t
            undo-tree-visualizer-diff t))
    :config
    (progn
      ;; restore diff window after quit.  TODO fix upstream
      (defun spacemacs/undo-tree-restore-default ()
        (setq undo-tree-visualizer-diff t))
      (advice-add 'undo-tree-visualizer-quit :after #'spacemacs/undo-tree-restore-default)
      (spacemacs|hide-lighter undo-tree-mode)
      (evilified-state-evilify-map undo-tree-visualizer-mode-map
        :mode undo-tree-visualizer-mode
        :bindings
        (kbd "j") 'undo-tree-visualize-redo
        (kbd "k") 'undo-tree-visualize-undo
        (kbd "h") 'undo-tree-visualize-switch-branch-left
        (kbd "l") 'undo-tree-visualize-switch-branch-right))))

(defun spacemacs-editing/init-uuidgen ()
  (use-package uuidgen
    :commands (uuidgen-1 uuidgen-4)
    :init
    (progn
      (spacemacs/declare-prefix "iU" "uuid")
      (spacemacs/set-leader-keys
        "iU1" 'spacemacs/uuidgen-1
        "iU4" 'spacemacs/uuidgen-4
        "iUU" 'spacemacs/uuidgen-4))))

(defun spacemacs-editing/init-ws-butler ()
  ;; not deferred on purpose, init-spacemacs-whitespace-cleanup need
  ;; it to be loaded.
  (use-package ws-butler
    :config (spacemacs|hide-lighter ws-butler-mode)))
