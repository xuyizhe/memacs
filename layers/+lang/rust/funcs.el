;;; funcs.el --- rust Layer functions File for Spacemacs
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: NJBS <DoNotTrackMeUsingThis@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defun spacemacs//rust-backend ()
  "Returns selected backend."
  (if rust-backend
      rust-backend
    (cond
     ((configuration-layer/layer-used-p 'lsp) 'lsp)
     (t 'racer))))

(defun spacemacs//rust-setup-backend ()
  "Conditionally setup rust backend."
  (pcase (spacemacs//rust-backend)
    (`racer (spacemacs//rust-setup-racer))
    (`lsp (spacemacs//rust-setup-lsp))))

(defun spacemacs//rust-setup-company ()
  "Conditionally setup company based on backend."
  (pcase (spacemacs//rust-backend)
    (`racer (spacemacs//rust-setup-racer-company))
    (`lsp (spacemacs//rust-setup-lsp-company))))

(defun spacemacs//rust-setup-dap ()
  "Conditionally setup elixir DAP integration."
  ;; currently DAP is only available using LSP
  (pcase (spacemacs//rust-backend)
    (`lsp (spacemacs//java-setup-lsp-dap))))


;; lsp

(defun spacemacs//rust-setup-lsp ()
  "Setup lsp backend"
  (if (configuration-layer/layer-used-p 'lsp)
      (lsp)
    (message "`lsp' layer is not installed, please add `lsp' layer to your dotfile.")))

(defun spacemacs//rust-setup-lsp-company ()
  "Setup lsp auto-completion."
  (if (configuration-layer/layer-used-p 'lsp)
      (progn
        (spacemacs|add-company-backends
          :backends company-lsp
          :modes rust-mode))
    (message "`lsp' layer is not installed, please add `lsp' layer to your dotfile.")))

(defun spacemacs//rust-setup-lsp-dap ()
  "Setup DAP integration."
  (require 'dap-gdb-lldb))


;; racer

(defun spacemacs//rust-setup-racer ()
  "Setup racer backend"
  (progn
    (racer-mode)))

(defun spacemacs//rust-setup-racer-company ()
  "Setup racer auto-completion."
  (spacemacs|add-company-backends
    :backends company-capf
    :modes rust-mode
    :variables company-tooltip-align-annotations t))

(defun spacemacs/racer-describe ()
  "Show a *Racer Help* buffer for the function or type at point.
If `help-window-select' is non-nil, also select the help window."
  (interactive)
  (let ((window (racer-describe)))
    (when help-window-select
      (select-window window))))

;; Misc

(defun spacemacs/rust-quick-run ()
  "Quickly run a Rust file using rustc.
Meant for a quick-prototype flow only - use `spacemacs/open-junk-file' to
open a junk Rust file, type in some code and quickly run it.
If you want to use third-party crates, create a new project using `cargo-process-new' and run
using `cargo-process-run'."
  (interactive)
  (let ((input-file-name (buffer-file-name))
        (output-file-name (concat temporary-file-directory (make-temp-name "rustbin"))))
    (compile
     (format "rustc -o %s %s && %s"
             (shell-quote-argument output-file-name)
             (shell-quote-argument input-file-name)
             (shell-quote-argument output-file-name)))))
