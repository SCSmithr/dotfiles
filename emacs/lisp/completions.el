;;; completions.el --- Completions

(use-package company
  :straight t
  :config
  (setq company-frontends '(company-posframe-frontend))
  (setq company-minimum-prefix-length 1)
  (setq company-idle-delay 0.2)
  (define-key company-active-map (kbd "<tab>") #'company-complete-selection)
  (setq company-backends (delete 'company-dabbrev company-backends))
  :init
  (add-hook 'after-init-hook 'global-company-mode))

(use-package company-posframe
  :straight t)

(use-package company-lsp
  :straight t
  :after (company lsp)
  :config
  (add-to-list 'company-lsp-filter-candidates '(gopls . nil))
  (push 'company-lsp company-backends))

(use-package lsp-mode
  :straight t
  :config
  (setq lsp-prefer-flymake nil)
  (setq lsp-auto-guess-root t)
  (setq lsp-response-timeout 2)
  :commands lsp)

(use-package lsp-ui
  :straight t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-enable nil
        lsp-ui-peek-enable nil
        lsp-ui-sideline-enable nil
        lsp-ui-imenu-enable nil
        lsp-ui-flycheck-enable t)
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))

(provide 'completions)
;;; completions.el ends here
