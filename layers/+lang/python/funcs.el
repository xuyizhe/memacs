;;; funcs.el --- Python Layer functions File for Spacemacs
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defun spacemacs//python-backend ()
  "Returns selected backend."
  (if python-backend
      python-backend
    (when (configuration-layer/layer-used-p 'lsp) 'lsp)
    ))

(defun spacemacs//python-setup-backend ()
  "Conditionally setup python backend."
  (pcase python-backend
    (`lsp (spacemacs//python-setup-lsp))))

(defun spacemacs//python-setup-company ()
  "Conditionally setup company based on backend."
  (pcase (spacemacs//python-backend)
    (`lsp (spacemacs//python-setup-lsp-company))))

(defun spacemacs//python-setup-dap ()
  "Conditionally setup elixir DAP integration."
  ;; currently DAP is only available using LSP
  (pcase (spacemacs//python-backend)
    (`lsp (spacemacs//python-setup-lsp-dap))))

(defun spacemacs//python-setup-eldoc ()
  "Conditionally setup eldoc based on backend."
  (pcase (spacemacs//python-backend)
    ;; lsp setup eldoc on its own
    (`lsp (message "lsp setup eldoc on its own."))))


;; lsp

(defun spacemacs//python-setup-lsp ()
  "Setup lsp backend."
  (if (configuration-layer/layer-used-p 'lsp)
      (progn
        (when (eq python-lsp-server 'mspyls)
          (require 'lsp-python-ms))
        (lsp))
    (message "`lsp' layer is not installed, please add `lsp' layer to your dotfile.")))

(defun spacemacs//python-setup-lsp-company ()
  "Setup lsp auto-completion."
  (if (configuration-layer/layer-used-p 'lsp)
      (progn
        (spacemacs|add-company-backends
          :backends company-lsp
          :modes python-mode
          :append-hooks nil
          :call-hooks t)
        (company-mode))
    (message "`lsp' layer is not installed, please add `lsp' layer to your dotfile.")))

(defun spacemacs//python-setup-lsp-dap ()
  "Setup DAP integration."
  (require 'dap-python))


;; others

(defun spacemacs//python-default ()
  "Defaut settings for python buffers"
  (setq mode-name "Python"
        tab-width python-tab-width
        fill-column python-fill-column)

  (setq-local comment-inline-offset 2)
  (spacemacs/python-annotate-pdb)
  ;; make C-j work the same way as RET
  (local-set-key (kbd "C-j") 'newline-and-indent))

;; from http://pedrokroger.net/2010/07/configuring-emacs-as-a-python-ide-2/
(defun spacemacs/python-annotate-pdb ()
  "Highlight break point lines."
  (interactive)
  (highlight-lines-matching-regexp "breakpoint()")
  (highlight-lines-matching-regexp "import \\(pdb\\|ipdb\\|pudb\\|wdb\\)")
  (highlight-lines-matching-regexp "\\(pdb\\|ipdb\\|pudb\\|wdb\\).set_trace()")
  (highlight-lines-matching-regexp "trepan.api.debug()"))

(defun spacemacs/pyenv-executable-find (command)
  "Find executable taking pyenv shims into account.
If the executable is a system executable and not in the same path
as the pyenv version then also return nil. This works around https://github.com/pyenv/pyenv-which-ext
"
  (if (executable-find "pyenv")
      (progn
        (let ((pyenv-string (shell-command-to-string (concat "pyenv which " command)))
              (pyenv-version-names (split-string (string-trim (shell-command-to-string "pyenv version-name")) ":"))
              (executable nil)
              (i 0))
          (if (not (string-match "not found" pyenv-string))
              (while (and (not executable)
                          (< i (length pyenv-version-names)))
                (if (string-match (elt pyenv-version-names i) (string-trim pyenv-string))
                    (setq executable (string-trim pyenv-string)))
                (if (string-match (elt pyenv-version-names i) "system")
                    (setq executable (string-trim (executable-find command))))
                (setq i (1+ i))))
          executable))
    (executable-find command)))

(defun spacemacs//python-setup-shell (&rest args)
  (if (spacemacs/pyenv-executable-find "ipython")
      (progn (setq python-shell-interpreter "ipython")
             (if (version< (replace-regexp-in-string "[\r\n|\n]$" "" (shell-command-to-string (format "\"%s\" --version" (string-trim (spacemacs/pyenv-executable-find "ipython"))))) "5")
                 (setq python-shell-interpreter-args "-i")
               (setq python-shell-interpreter-args "--simple-prompt -i")))
    (progn
      (setq python-shell-interpreter-args "-i")
      (setq python-shell-interpreter "python"))))


(defun spacemacs//python-setup-checkers (&rest args)
  (when (fboundp 'flycheck-set-checker-executable)
    (let ((pylint (spacemacs/pyenv-executable-find "pylint"))
          (flake8 (spacemacs/pyenv-executable-find "flake8")))
      (when pylint
        (flycheck-set-checker-executable "python-pylint" pylint))
      (when flake8
        (flycheck-set-checker-executable "python-flake8" flake8)))))

(defun spacemacs/python-setup-everything (&rest args)
  (apply 'spacemacs//python-setup-shell args)
  (apply 'spacemacs//python-setup-checkers args))

(defun spacemacs/python-toggle-breakpoint ()
  "Add a break point, highlight it."
  (interactive)
  (let ((trace (cond ((spacemacs/pyenv-executable-find "trepan3k") "import trepan.api; trepan.api.debug()")
                     ((spacemacs/pyenv-executable-find "wdb") "import wdb; wdb.set_trace()")
                     ((spacemacs/pyenv-executable-find "ipdb") "import ipdb; ipdb.set_trace()")
                     ((spacemacs/pyenv-executable-find "pudb") "import pudb; pudb.set_trace()")
                     ((spacemacs/pyenv-executable-find "ipdb3") "import ipdb; ipdb.set_trace()")
                     ((spacemacs/pyenv-executable-find "pudb3") "import pudb; pudb.set_trace()")
                     ((spacemacs/pyenv-executable-find "python3.7") "breakpoint()")
                     ((spacemacs/pyenv-executable-find "python3.8") "breakpoint()")
                     (t "import pdb; pdb.set_trace()")))
        (line (thing-at-point 'line)))
    (if (and line (string-match trace line))
        (kill-whole-line)
      (progn
        (back-to-indentation)
        (insert trace)
        (insert "\n")
        (python-indent-line)))))

;; from https://www.snip2code.com/Snippet/127022/Emacs-auto-remove-unused-import-statemen
(defun spacemacs/python-remove-unused-imports()
  "Use Autoflake to remove unused function"
  "autoflake --remove-all-unused-imports -i unused_imports.py"
  (interactive)
  (if (executable-find "autoflake")
    (progn
      (shell-command (format "autoflake --remove-all-unused-imports -i %s"
                       (shell-quote-argument (buffer-file-name))))
      (revert-buffer t t t))
    (message "Error: Cannot find autoflake executable.")))

(defun spacemacs//pyvenv-mode-set-local-virtualenv ()
  "Set pyvenv virtualenv from \".venv\" by looking in parent directories. handle directory or file"
  (interactive)
  (let ((root-path (locate-dominating-file default-directory
                                           ".venv")))
    (when root-path
      (let* ((file-path (expand-file-name ".venv" root-path))
             (virtualenv
              (if (file-directory-p file-path)
                  file-path
                (with-temp-buffer
                  (insert-file-contents-literally file-path)
                  (buffer-substring-no-properties (line-beginning-position)
                                                  (line-end-position))))))
        (if (file-directory-p virtualenv)
            (pyvenv-activate virtualenv)
          (pyvenv-workon virtualenv))))))


;; Tests

;; fix for issue #2569 (https://github.com/syl20bnr/spacemacs/issues/2569) and
;; Emacs 24.5 and older. use `semantic-create-imenu-index' only when
;; `semantic-mode' is enabled, otherwise use `python-imenu-create-index'
(defun spacemacs/python-imenu-create-index ()
  (if (bound-and-true-p semantic-mode)
      (semantic-create-imenu-index)
    (python-imenu-create-index)))

(defun spacemacs//python-get-main-testrunner ()
  "Get the main test runner."
  (if (listp python-test-runner) (car python-test-runner) python-test-runner))

(defun spacemacs//python-get-secondary-testrunner ()
  "Get the secondary test runner"
  (cdr (assoc (spacemacs//python-get-main-testrunner) '((pytest . nose)
                                             (nose . pytest)))))

(defun spacemacs//python-call-correct-test-function (arg funcalist)
  "Call a test function based on the chosen test framework.
ARG is the universal-argument which chooses between the main and
the secondary test runner. FUNCALIST is an alist of the function
to be called for each testrunner. "
  (when python-save-before-test
      (save-buffer))
  (let* ((test-runner (if arg
                          (spacemacs//python-get-secondary-testrunner)
                        (spacemacs//python-get-main-testrunner)))
         (test-function (assq test-runner funcalist)))
    (if test-function
        (funcall (cdr (assoc test-runner funcalist)))
      (user-error "This test function is not available with the `%S' runner."
                  test-runner))))

(defun spacemacs/python-test-last (arg)
  "Re-run the last test command"
  (interactive "P")
  (spacemacs//python-call-correct-test-function arg '((nose . nosetests-again))))

(defun spacemacs/python-test-all (arg)
  "Run all tests."
  (interactive "P")
  (spacemacs//python-call-correct-test-function arg '((pytest . pytest-all)
                                           (nose . nosetests-all))))

(defun spacemacs/python-test-pdb-all (arg)
  "Run all tests in debug mode."
  (interactive "P")
  (spacemacs//python-call-correct-test-function arg '((pytest . pytest-pdb-all)
                                           (nose . nosetests-pdb-all))))

(defun spacemacs/python-test-module (arg)
  "Run all tests in the current module."
  (interactive "P")
  (spacemacs//python-call-correct-test-function arg '((pytest . pytest-module)
                                           (nose . nosetests-module))))

(defun spacemacs/python-test-pdb-module (arg)
  "Run all tests in the current module in debug mode."
  (interactive "P")
  (spacemacs//python-call-correct-test-function
   arg
   '((pytest . pytest-pdb-module)
     (nose . nosetests-pdb-module))))

(defun spacemacs/python-test-suite (arg)
  "Run all tests in the current suite."
  (interactive "P")
  (spacemacs//python-call-correct-test-function arg '((nose . nosetests-suite))))

(defun spacemacs/python-test-pdb-suite (arg)
  "Run all tests in the current suite in debug mode."
  (interactive "P")
  (spacemacs//python-call-correct-test-function arg '((nose . nosetests-pdb-suite))))

(defun spacemacs/python-test-one (arg)
  "Run current test."
  (interactive "P")
  (spacemacs//python-call-correct-test-function arg '((pytest . pytest-one)
                                           (nose . nosetests-one))))

(defun spacemacs/python-test-pdb-one (arg)
  "Run current test in debug mode."
  (interactive "P")
  (spacemacs//python-call-correct-test-function arg '((pytest . pytest-pdb-one)
                                           (nose . nosetests-pdb-one))))

(defun spacemacs//python-sort-imports ()
  ;; py-isort-before-save checks the major mode as well, however we can prevent
  ;; it from loading the package unnecessarily by doing our own check
  (when (and python-sort-imports-on-save
             (derived-mode-p 'python-mode))
    (py-isort-before-save)))


;; Formatters

(defun spacemacs//bind-python-formatter-keys ()
  "Bind the python formatter keys.
Bind formatter to '==' for LSP and '='for all other backends."
  (spacemacs/set-leader-keys-for-major-mode 'python-mode
    (if (eq (spacemacs//python-backend) 'lsp)
        "=="
      "=") 'spacemacs/python-format-buffer))

(defun spacemacs/python-format-buffer ()
  "Bind possible python formatters."
  (interactive)
  (pcase python-formatter
    (`yapf (yapfify-buffer))
    (`black (blacken-buffer))
    (`lsp (lsp-format-buffer))
    (code (message "Unknown formatter: %S" code))))


;; REPL

(defun spacemacs/python-shell-send-buffer-switch ()
  "Send buffer content to shell and switch to it in insert mode."
  (interactive)
  (let ((python-mode-hook nil))
    (python-shell-send-buffer)
    (python-shell-switch-to-shell)
    (evil-insert-state)))

(defun spacemacs/python-shell-send-buffer ()
  "Send buffer content to shell and switch to it in insert mode."
  (interactive)
  (let ((python-mode-hook nil))
    (python-shell-send-buffer)))

(defun spacemacs/python-shell-send-defun-switch ()
  "Send function content to shell and switch to it in insert mode."
  (interactive)
  (let ((python-mode-hook nil))
    (python-shell-send-defun nil)
    (python-shell-switch-to-shell)
    (evil-insert-state)))

(defun spacemacs/python-shell-send-defun ()
  "Send function content to shell and switch to it in insert mode."
  (interactive)
  (let ((python-mode-hook nil))
    (python-shell-send-defun nil)))

(defun spacemacs/python-shell-send-region-switch (start end)
  "Send region content to shell and switch to it in insert mode."
  (interactive "r")
  (let ((python-mode-hook nil))
    (python-shell-send-region start end)
    (python-shell-switch-to-shell)
    (evil-insert-state)))

(defun spacemacs/python-shell-send-region (start end)
  "Send region content to shell and switch to it in insert mode."
  (interactive "r")
  (let ((python-mode-hook nil))
    (python-shell-send-region start end)))

(defun spacemacs/python-start-or-switch-repl ()
  "Start and/or switch to the REPL."
  (interactive)
  (let ((shell-process
         (or (python-shell-get-process)
             ;; `run-python' has different return values and different
             ;; errors in different emacs versions. In 24.4, it throws an
             ;; error when the process didn't start, but in 25.1 it
             ;; doesn't throw an error, so we demote errors here and
             ;; check the process later
             (with-demoted-errors "Error: %S"
               ;; in Emacs 24.5 and 24.4, `run-python' doesn't return the
               ;; shell process
               (call-interactively #'run-python)
               (python-shell-get-process)))))
    (unless shell-process
      (error "Failed to start python shell properly"))
    (pop-to-buffer (process-buffer shell-process))
    (evil-insert-state)))

(defun spacemacs/python-execute-file (arg)
  "Execute a python script in a shell."
  (interactive "P")
  ;; set compile command to buffer-file-name
  ;; universal argument put compile buffer in comint mode
  (let ((universal-argument t)
        (compile-command (format "%s %s"
                                 (spacemacs/pyenv-executable-find python-shell-interpreter)
                                 (shell-quote-argument (file-name-nondirectory buffer-file-name)))))
    (if arg
        (call-interactively 'compile)
      (compile compile-command t)
      (with-current-buffer (get-buffer "*compilation*")
        (inferior-python-mode)))))

(defun spacemacs/python-execute-file-focus (arg)
  "Execute a python script in a shell and switch to the shell buffer in
 `insert state'."
  (interactive "P")
  (spacemacs/python-execute-file arg)
  (switch-to-buffer-other-window "*compilation*")
  (end-of-buffer)
  (evil-insert-state))

(defun spacemacs//bind-python-repl-keys ()
  "Bind the keys for testing in Python."
  (spacemacs/declare-prefix-for-mode 'inferior-python-mode "v" "virtualenv")
  (spacemacs/set-leader-keys-for-major-mode 'inferior-python-mode
    "c" 'comint-clear-buffer
    "r" 'pyvenv-restart-python
    "vw" 'pyvenv-workon))
