;;; packages.el --- go layer keybindings file for Spacemacs.
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Mephis Pheies <mephistommm@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3


;;; go-mode
(spacemacs/declare-prefix-for-mode 'go-mode "e" "playground")
(spacemacs/declare-prefix-for-mode 'go-mode "g" "goto")
(spacemacs/declare-prefix-for-mode 'go-mode "h" "help")
(spacemacs/declare-prefix-for-mode 'go-mode "i" "imports")
(spacemacs/declare-prefix-for-mode 'go-mode "r" "refactoring")
(spacemacs/declare-prefix-for-mode 'go-mode "t" "test")
(spacemacs/declare-prefix-for-mode 'go-mode "x" "execute")
(spacemacs/declare-prefix-for-mode 'go-mode "tg" "generate")
(spacemacs/declare-prefix-for-mode 'go-mode "T" "toggle")
(spacemacs/set-leader-keys-for-major-mode 'go-mode
  "=="  'gofmt
  "hh" 'godoc-at-point
  "ig" 'go-goto-imports
  "ia" 'go-import-add
  "ir" 'go-remove-unused-imports
  "eb" 'go-play-buffer
  "er" 'go-play-region
  "ed" 'go-download-play
  "xx" 'spacemacs/go-run-main
  "ga" 'ff-find-other-file
  "gc" 'go-coverage
  "tt" 'spacemacs/go-run-test-current-function
  "ts" 'spacemacs/go-run-test-current-suite
  "tp" 'spacemacs/go-run-package-tests
  "tP" 'spacemacs/go-run-package-tests-nested)

;;;; go guru
(spacemacs/declare-prefix-for-mode 'go-mode "f" "guru")
(spacemacs/set-leader-keys-for-major-mode 'go-mode
  "fd" 'go-guru-describe
  "ff" 'go-guru-freevars
  "fi" 'go-guru-implements
  "fc" 'go-guru-peers
  "fr" 'go-guru-referrers
  "fj" 'go-guru-definition
  "fp" 'go-guru-pointsto
  "fs" 'go-guru-callstack
  "fe" 'go-guru-whicherrs
  "f<" 'go-guru-callers
  "f>" 'go-guru-callees
  "fo" 'go-guru-set-scope)

;;;; go rename
(spacemacs/set-leader-keys-for-major-mode 'go-mode "rN" 'go-rename)

;;;; go doctor
(spacemacs/set-leader-keys-for-major-mode 'go-mode
  "rn" 'godoctor-rename
  "re" 'godoctor-extract
  "rt" 'godoctor-toggle
  "rd" 'godoctor-godoc)

;;;; go tag
(spacemacs/set-leader-keys-for-major-mode 'go-mode
  "rf" 'go-tag-add
  "rF" 'go-tag-remove)

;;;; go impl
(spacemacs/set-leader-keys-for-major-mode 'go-mode
  "ri" 'go-impl)

;;;; go gen test
(spacemacs/set-leader-keys-for-major-mode 'go-mode
  "tgg" 'go-gen-test-dwim
  "tgf" 'go-gen-test-exported
  "tgF" 'go-gen-test-all)

;;;; go fill struct
(spacemacs/set-leader-keys-for-major-mode 'go-mode
  "rs" 'go-fill-struct)

;;;; xref
(spacemacs/set-leader-keys-for-major-mode 'go-mode
  (kbd "gr") #'xref-find-references)

;;;; Goenv
(with-eval-after-load 'go-mode
  (spacemacs/set-leader-keys-for-major-mode 'go-mode "Va" 'goenv-activate)
  (spacemacs/set-leader-keys-for-major-mode 'go-mode "Vd" 'goenv-deactivate))
