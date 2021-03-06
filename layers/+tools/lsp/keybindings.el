;;; lsp/keybindings.el --- define keybindings for lsp layer

;; Author: Mephis Pheies <mephistommm@gmail.com>
;; Keywords: lsp keybindings

;;; Code:


;;;; lsp ui
(define-key evil-normal-state-map (kbd "C-n") 'lsp-ui-peek-jump-forward)
(define-key evil-normal-state-map (kbd "C-p") 'lsp-ui-peek-jump-backward)
(define-key evil-normal-state-map (kbd "C-q") #'memacs/toggle-lsp-ui-doc)

;;; lsp/keybindings.el ends here
