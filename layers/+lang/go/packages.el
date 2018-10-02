;;; packages.el --- Go Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq go-packages
      '(
        company
        (company-go :requires company)
        flycheck
        ggtags
        helm-gtags
        go-eldoc
        go-fill-struct
        go-gen-test
        go-guru
        go-impl
        go-mode
        go-rename
        go-tag
        godoctor
        (lsp-go
         :requires lsp-mode
         :location (recipe :fetcher github
                           :repo "emacs-lsp/lsp-go"))
        popwin
        ))

(defun go/init-company-go ()
  (use-package company-go
    :defer t
    :init (spacemacs|add-company-backends
            :backends company-go
            :modes go-mode
            :variables company-go-show-annotation t)))

(defun go/init-lsp-go ()
  (use-package lsp-go
    :commands lsp-go-enable))

(defun go/post-init-company ()
  (add-hook 'go-mode-local-vars-hook #'spacemacs//go-setup-company))

(defun go/post-init-flycheck ()
  (spacemacs/enable-flycheck 'go-mode))

(defun go/post-init-ggtags ()
  (add-hook 'go-mode-local-vars-hook #'spacemacs/ggtags-mode-enable))

(defun go/post-init-helm-gtags ()
  (spacemacs/helm-gtags-define-keys-for-mode 'go-mode))

(defun go/init-go-eldoc ()
  (add-hook 'go-mode-hook 'go-eldoc-setup))

(defun go/init-go-fill-struct ()
  (use-package go-fill-struct
    :defer t
    ))

(defun go/init-go-gen-test()
  (use-package go-gen-test
    :defer t))

(defun go/init-go-guru ()
  (use-package go-impl
    :defer t))

(defun go/init-go-impl()
  (use-package go-impl
    :defer t))

(defun go/init-go-mode()
  (use-package go-mode
    :defer t
    :init
    (progn
      ;; get go packages much faster
      (setq go-packages-function 'spacemacs/go-packages-gopkgs)
      (add-hook 'go-mode-hook 'spacemacs//go-set-tab-width)
      (add-hook 'go-mode-local-vars-hook
                #'spacemacs//go-setup-backend)
      (dolist (value '(lsp go-mode))
        (add-to-list 'safe-local-variable-values
                     (cons 'go-backend value)))
      ;; Change flycheck-disabled-checkers
      (with-eval-after-load 'flycheck
        (add-hook 'flycheck-mode-hook (lambda ()
                                        (add-to-list 'flycheck-disabled-checkers 'go-vet)
                                        (add-to-list 'flycheck-disabled-checkers 'go-gofmt)
                                        (add-to-list 'flycheck-disabled-checkers 'go-errcheck)
                                        ))))
    :config
    (when go-format-before-save
      (add-hook 'before-save-hook 'gofmt-before-save))
    ))

(defun go/init-go-rename ()
  (use-package go-rename
    :defer t))

(defun go/init-godoctor ()
  (use-package godoctor
    :defer t))

(defun go/init-go-tag ()
  (use-package go-tag
    :defer t))

(defun go/post-init-popwin ()
  (push (cons go-test-buffer-name '(:dedicated t :position bottom :stick t :noselect t :height 0.4))
        popwin:special-display-config))
