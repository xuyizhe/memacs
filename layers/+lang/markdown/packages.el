;;; packages.el --- Markdown Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq markdown-packages
      '(
        company
        company-emoji
        emoji-cheat-sheet-plus
        gh-md
        markdown-mode
        markdown-toc
        ))

(defun markdown/post-init-company ()
  (dolist (mode markdown--key-bindings-modes)
    (eval `(spacemacs|add-company-backends
             :backends company-capf
             :modes ,mode))))

(defun markdown/post-init-company-emoji ()
  (dolist (mode markdown--key-bindings-modes)
    (eval `(spacemacs|add-company-backends
             :backends company-emoji
             :modes ,mode))))

(defun markdown/post-init-emoji-cheat-sheet-plus ()
  (add-hook 'markdown-mode-hook 'emoji-cheat-sheet-plus-display-mode))

(defun markdown/init-gh-md ()
  (use-package gh-md
    :defer t
    :init
    (dolist (mode markdown--key-bindings-modes)
      (spacemacs/set-leader-keys-for-major-mode mode
        "cr" 'gh-md-render-buffer))))

(defun markdown/init-markdown-mode ()
  (use-package markdown-mode
    :mode
    (("\\.m[k]d" . markdown-mode)
     ("\\.mdk" . markdown-mode))
    :defer t
    :config
    (progn
      ;; Declare prefixes and bind keys
      (dolist (prefix '(("c" . "markdown/command")
                        ("h" . "markdown/header")
                        ("i" . "markdown/insert")
                        ("l" . "markdown/lists")
                        ("t" . "markdown/table")
                        ("T" . "markdown/toggle")
                        ("x" . "markdown/text")))
        (dolist (mode markdown--key-bindings-modes)
          (spacemacs/declare-prefix-for-mode
            mode (car prefix) (cdr prefix))))
      (dolist (mode markdown--key-bindings-modes)
        (spacemacs/set-leader-keys-for-major-mode mode
          ;; rebind this so terminal users can use it
          "M-RET" 'markdown-insert-list-item
          ;; Movement
          "{"   'markdown-backward-paragraph
          "}"   'markdown-forward-paragraph
          ;; Completion, and Cycling
          "]"   'markdown-complete
          ;; Indentation
          ">"   'markdown-indent-region
          "<"   'markdown-outdent-region
          ;; Buffer-wide commands
          "c]"  'markdown-complete-buffer
          "cc"  'markdown-check-refs
          "ce"  'markdown-export
          "cm"  'markdown-other-window
          "cn"  'markdown-cleanup-list-numbers
          "co"  'markdown-open
          "cp"  'markdown-preview
          "cv"  'markdown-export-and-preview
          "cw"  'markdown-kill-ring-save
          ;; headings
          "hi"  'markdown-insert-header-dwim
          "hI"  'markdown-insert-header-setext-dwim
          "h1"  'markdown-insert-header-atx-1
          "h2"  'markdown-insert-header-atx-2
          "h3"  'markdown-insert-header-atx-3
          "h4"  'markdown-insert-header-atx-4
          "h5"  'markdown-insert-header-atx-5
          "h6"  'markdown-insert-header-atx-6
          "h!"  'markdown-insert-header-setext-1
          "h@"  'markdown-insert-header-setext-2
          ;; Insertion of common elements
          "-"   'markdown-insert-hr
          "if"  'markdown-insert-footnote
          "ii"  'markdown-insert-image
          "ik"  'spacemacs/insert-keybinding-markdown
          "il"  'markdown-insert-link
          "iw"  'markdown-insert-wiki-link
          "iu"  'markdown-insert-uri
          ;; Element removal
          "k"   'markdown-kill-thing-at-point
          ;; List editing
          "li"  'markdown-insert-list-item
          ;; Toggles
          "Ti"  'markdown-toggle-inline-images
          "Tl"  'markdown-toggle-url-hiding
          "Tm"  'markdown-toggle-markup-hiding
          "Tt"  'markdown-toggle-gfm-checkbox
          "Tw"  'markdown-toggle-wiki-links
          ;; Table
          "tp"  'markdown-table-move-row-up
          "tn"  'markdown-table-move-row-down
          "tf"  'markdown-table-move-column-right
          "tb"  'markdown-table-move-column-left
          "tr"  'markdown-table-insert-row
          "tR"  'markdown-table-delete-row
          "tc"  'markdown-table-insert-column
          "tC"  'markdown-table-delete-column
          "ts"  'markdown-table-sort-lines
          "td"  'markdown-table-convert-region
          "tt"  'markdown-table-transpose
          ;; region manipulation
          "xb"  'markdown-insert-bold
          "xB"  'markdown-insert-gfm-checkbox
          "xc"  'markdown-insert-code
          "xC"  'markdown-insert-gfm-code-block
          "xi"  'markdown-insert-italic
          "xp"  'markdown-insert-pre
          "xq"  'markdown-insert-blockquote
          "xs"  'markdown-insert-strike-through
          "xQ"  'markdown-blockquote-region
          "xP"  'markdown-pre-region
          ;; Following and Jumping
          "N"   'markdown-next-link
          "f"   'markdown-follow-thing-at-point
          "P"   'markdown-previous-link
          "<RET>" 'markdown-do))
      ;; Header navigation in normal state movements
      (evil-define-key 'normal markdown-mode-map
        "gj" 'outline-forward-same-level
        "gk" 'outline-backward-same-level
        "gh" 'outline-up-heading
        ;; next visible heading is not exactly what we want but close enough
        "gl" 'outline-next-visible-heading)
      ;; Promotion, Demotion
      (spacemacs//markdown-hjkl-promotion-demotion 'hybrid)
      (define-key markdown-mode-map (kbd "M-<down>") 'markdown-move-down)
      (define-key markdown-mode-map (kbd "M-<left>") 'markdown-promote)
      (define-key markdown-mode-map (kbd "M-<right>") 'markdown-demote)
      (define-key markdown-mode-map (kbd "M-<up>") 'markdown-move-up))))

(defun markdown/init-markdown-toc ()
  (use-package markdown-toc
    :defer t
    :init
    (dolist (mode markdown--key-bindings-modes)
      (spacemacs/set-leader-keys-for-major-mode mode
        "it" 'markdown-toc-generate-toc))))
