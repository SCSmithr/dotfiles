;;; seanmacs-langs.el --- Langs -*- lexical-binding: t; -*-

;;; Commentary:
;; Language configuration.

;;; Code:

;; Go

(use-package go-mode
  :straight t
  :defer t
  :commands gofmt
  :init
  (defun seanmacs/gofmt-before-save ()
    (when (eq major-mode 'go-mode)
      (gofmt)))
  :config
  (setq gofmt-command "goimports"
        gofmt-args '("-local=go.coder.com"))
  (evil-collection-define-key 'normal 'go-mode-map
    "gd" 'lsp-find-definition)
  :hook ((go-mode . lsp)
         (before-save . seanmacs/gofmt-before-save))
  :bind(:map go-mode-map
             ("C-c C-d" . lsp-describe-thing-at-point)
             ("C-c r r" . lsp-rename)))

(use-package flycheck-golangci-lint
  :straight t
  :defer t
  :config
  (setq flycheck-golangci-lint-tests t
        flycheck-golangci-lint-fast t)

  (with-eval-after-load 'lsp-mode
    (flycheck-add-next-checker 'lsp 'golangci-lint 'append))
  :hook ((go-mode . flycheck-golangci-lint-setup)))

;; Haskell

(use-package haskell-mode
  :straight t
  :defer t
  :config
  (setq haskell-stylish-on-save t
        haskell-mode-stylish-haskell-path "brittany")
  (evil-add-command-properties #'haskell-mode-jump-to-def :jump t)
  (evil-collection-define-key 'normal 'haskell-mode-map
    "gd" 'haskell-mode-jump-to-def)
  :hook ((haskell-mode . interactive-haskell-mode)))

;; Octave

(use-package octave
  :defer t
  :mode ("\\.m\\'" . octave-mode))

;; Rust

(use-package rust-mode
  :straight t
  :defer t
  :config
  (setq rust-format-on-save t
        lsp-rust-clippy-preference "on")
  :hook ((rust-mode . lsp)
         (rust-mode . cargo-minor-mode))
  :bind(:map rust-mode-map
             ("C-c C-d" . lsp-describe-thing-at-point)
             ("C-c r r" . lsp-rename)))

(use-package cargo
  :straight t
  :defer t)

;; Python

(use-package elpy
  :straight t
  :defer t
  :init
  (advice-add 'python-mode :before 'elpy-enable)
  (defun seanmacs/disable-highlight-indentation ()
    (highlight-indentation-mode -1))
  :hook ((elpy-mode . seanmacs/disable-highlight-indentation)))

;; Typescript

(defun seanmacs/bin-from-node-modules (bin)
  "Return the full path if BIN exists in dominating node modules
dir. Return nil otherwise."
  (let* ((dir (or (projectile-project-root)
                  (buffer-file-name)
                  default-directory))
         (root (locate-dominating-file dir "node_modules"))
         (rel-path (format "node_modules/.bin/%s" bin))
         (path (and root (expand-file-name rel-path root))))
    (when (and path (file-executable-p path))
      path)))

(use-package tide
  :straight t
  :defer t
  :commands tide-setup)

(use-package prettier-js
  :straight t
  :defer t
  :init
  (defun seanmacs/use-node-modules-prettier ()
    (when-let ((prettier (seanmacs/bin-from-node-modules "prettier")))
      (setq-local prettier-js-command prettier)))
  :hook ((prettier-js-mode . seanmacs/use-node-modules-prettier)))

(use-package web-mode
  :straight t
  :defer t
  :mode (("\\.html?\\'" . web-mode)
         ("\\.tsx?\\'" . web-mode)
         ("\\.jsx\\'" . web-mode))
  :init
  (defun seanmacs/use-node-modules-eslint ()
    (when-let ((eslint (seanmacs/bin-from-node-modules "eslint")))
      (setq-local flycheck-javascript-eslint-executable eslint)))

  (defun seanmacs/setup-tide ()
    (when (string-match-p "tsx?" (file-name-extension buffer-file-name))
      (tide-setup)
      (tide-hl-identifier-mode +1)
      (prettier-js-mode)
      (evil-add-command-properties #'tide-jump-to-definition :jump t)
      (flycheck-add-mode 'javascript-eslint 'web-mode)
      (flycheck-add-next-checker 'tsx-tide 'javascript-eslint 'append)))

  (defun seanmacs/reset-web-mode-offsets ()
    (dtrt-indent-adapt) ;; Only runs once per buffer, no harm in calling it here.
    (setq-local web-mode-code-indent-offset standard-indent)
    (setq-local web-mode-css-indent-offset standard-indent)
    (setq-local web-mode-markup-indent-offset standard-indent))
  :config
  (setq web-mode-comment-style 1
        web-mode-enable-css-colorization t
        web-mode-enable-auto-pairing t
        web-mode-enable-comment-keywords t
        web-mode-enable-current-element-highlight t
        web-mode-enable-auto-quoting nil
        web-mode-enable-auto-indentation nil)
  :hook ((web-mode . seanmacs/setup-tide)
         (web-mode . seanmacs/use-node-modules-eslint)
         (web-mode . seanmacs/reset-web-mode-offsets))
  :bind (:map web-mode-map
              ("C-c C-d" . tide-documentation-at-point)
              ("C-c r r" . tide-rename-symbol)
              ("C-c r f" . tide-rename-file)))

;; Elixir

(use-package elixir-mode
  :straight t
  :defer t
  :init
  (defun seanmacs/elixir-format-on-save ()
    (when (eq major-mode 'elixir-mode)
      (elixir-format)))
  :config
  (evil-add-command-properties #'alchemist-goto-defintion-at-point :jump t)
  :hook ((elixir-mode . alchemist-mode)
         (before-save . seanmacs/elixir-format-on-save)))

(use-package alchemist
  :straight t
  :defer t)

;; Protobuf

(use-package protobuf-mode
  :straight t
  :defer t)

;; Common lisp

(use-package slime
  :straight t
  :defer t
  :config
  (setq inferior-lisp-program "sbcl"
        slime-contribs '(slime-fancy)))

;; Scheme

(use-package geiser
  :straight t
  :defer t)

;; Julia

(use-package julia-mode
  :straight t
  :defer t
  :hook ((julia-mode . julia-repl-mode)))

(use-package julia-repl
  :straight t
  :defer t
  :init
  (defun seanmacs/julia-repl-apropos (search)
    "Send apropos query to repl."
    (interactive (list (read-string "Apropos: ")))
    (julia-repl--send-string (format "apropos(\"%s\")" search)))

  (defun seanmacs/flush-empty-lines ()
    "Delete empty lines after point.

Term mode seems to add a newline after every input in line mode."
    (interactive)
    (flush-lines "^$"))

  (defun seanmacs/julia-repl-set-term-scroll ()
    "Sets term scroll to nil.

This is a workaround to avoid seeing all of the empty lines in
the repl. (See https://github.com/tpapp/julia-repl/issues/79)"
    (setq-local term-scroll-show-maximum-output nil))

  (defun seanmacs/julia-send-paragraph ()
    "Send the current paragraph to Julia REPL."
    (interactive)
    (let ((beg (save-excursion (backward-paragraph) (point)))
          (end (save-excursion (forward-paragraph) (point))))
      (julia-repl--send-string
       (buffer-substring-no-properties beg end))))

  :config
  (evil-add-command-properties #'julia-repl-edit :jump t)
  ;; Remove original doc keybind.
  (define-key julia-repl-mode-map (kbd "C-c C-d") nil)

  :hook ((julia-repl . seanmacs/julia-repl-set-term-scroll))
  :bind (:map julia-repl-mode-map
              ("C-c C-d C-d" . julia-repl-doc)
              ("C-c C-d d" . julia-repl-doc)
              ("C-c C-d C-a" . seanmacs/julia-repl-apropos)
              ("C-c C-d a" . seanmacs/julia-repl-apropos)))

;; Clojure

(use-package clojure-mode
  :straight t
  :defer t
  :config
  (define-clojure-indent
    (defroutes 'defun)
    (GET 2)
    (POST 2)
    (PUT 2)
    (DELETE 2)
    (HEAD 2)
    (ANY 2)
    (OPTIONS 2)
    (PATCH 2)
    (rfn 2)
    (let-routes 1)
    (context 2)))

(use-package cider
  :straight t
  :defer t
  :config
  (evil-add-command-properties #'cider-find-var :jump t))

;; Emacs lisp

(use-package elisp-mode
  ;; built-in
  :defer t
  :init
  (defun seanmacs/elisp-describe-symbol-at-point ()
    (interactive)
    (let ((sym (symbol-at-point)))
      (describe-symbol sym)))
  :bind (:map emacs-lisp-mode-map
              ("C-c C-d" . seanmacs/elisp-describe-symbol-at-point)
              :map lisp-interaction-mode-map
              ("C-c C-d" . seanmacs/elisp-describe-symbol-at-point)))

;; C/C++

(use-package ccls
  :straight t
  :defer t
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
         (lambda ()
           (require 'ccls)
           (lsp))))

;; Yaml

(use-package yaml-mode
  :straight t
  :defer t)

;; Markdown

(use-package markdown-mode
  :straight t
  :defer t
  :config
  (evil-collection-define-key 'normal 'markdown-mode-map
    (kbd "TAB") 'markdown-cycle))

;; Dockerfile

(use-package dockerfile-mode
  :straight t
  :defer t)

;; Nix

(use-package nix-mode
  :straight t
  :defer t)

;; Lean

(use-package lean-mode
  :straight t
  :defer t
  :config
  (setq lean-memory-limit 16384
        lean-extra-arguments '("-D class.instance_max_depth=1000"))
  (evil-add-command-properties #'lean-find-definition :jump t)
  (evil-collection-define-key 'normal 'lean-mode-map
    "gd" 'lean-find-definition))

;; Purescript

(defvar seanmacs/purescript-formatter "purty")

(use-package purescript-mode
  :straight t
  :defer t
  :init
  (reformatter-define purescript-format
    :program seanmacs/purescript-formatter
    :args '("-"))
  :config
  (evil-add-command-properties #'psc-ide-goto-definition :jump t)
  (evil-collection-define-key 'normal 'purescript-mode-map
    "gd" 'psc-ide-goto-definition)
  :bind(:map purescript-mode-map
             ("C-c C-r r" . psci)
             ("C-c C-r l" . psci/load-current-file!)
             ("C-c C-r m" . psci/load-module!))
  :hook ((purescript-mode . turn-on-purescript-indentation)
         (purescript-mode . psc-ide-mode)))

(use-package psc-ide
  :straight t
  :defer t)

(use-package psci
  :straight t
  :defer t
  :commands (psci psci/load-module! psci/load-current-file!))

(provide 'seanmacs-langs)
;;; seanmacs-langs.el ends here
