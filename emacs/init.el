;; Hide some things
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq use-dialog-box nil)
(setq inhibit-startup-message t
      inihibit-startup-echo-area-message t)

(defconst user-init-dir
  (cond ((boundp 'user-emacs-directory)
         user-emacs-directory)
        ((boundp 'user-init-directory)
         user-init-directory)
        (t "~/.emacs.d/")))

(defun load-user-file (file)
  "Load FILE in current user's configuration directory."
  (interactive "f")
  (load-file (expand-file-name file user-init-dir)))

(defun load-language (lang)
  "Load language specific packages for LANG."
  (interactive "f")
  (load-user-file
   (concat user-init-dir (concat "langs/" (concat lang "/packages.el")))))

;; Highlight parenthesis
(show-paren-mode 1)

;; Auto insert closing parenthesis, braces, etc
(electric-pair-mode 1)

;; Line numbers
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setq-default display-line-numbers-width-start t)

;; Highlight current line
(global-hl-line-mode +1)

;; Tab stuff
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'cperl-indent-level 'tab-width)

(setq-default fill-column 80)

;; Whitespace stuff
(require 'whitespace)
(setq whitespace-line-column 80)
(setq whitespace-style '(
    face
    space-mark
    tab-mark lines-tail
    trailing
    tabs
    spaces))
(add-hook 'prog-mode-hook 'whitespace-mode)

;; Don't wrap lines
(add-hook 'prog-mode-hook 'toggle-truncate-lines)

(setq-default scroll-step 1)
(setq-default scroll-margin 4)
(setq-default scroll-conservatively 101)

(setq-default require-final-newline t)

;; Configure file backups
(setq backup-directory-alist '(("." . "~/.emacs.d/.backups")))
(setq backup-by-copying t)
(setq delete-old-versions t)
(setq kept-new-versions 6)
(setq kept-old-versions 2)
(setq version-control t)

;; #Don't #create #lock #files
(setq create-lockfiles nil)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (ripgrep idomenu swoop lsp-ui company company-lsp magit git-gutter-fring doom-modeline rust-mode haskell-mode git-gutter-fringe which-key flx-ido web-mode tide flycheck lsp-mode go-mode treemacs-projectile treemacs-evil treemacs projectile ido-vertical-mode evil use-package))))

(set-face-attribute 'default nil
                    :weight 'normal
                    :font "Source Code Pro Medium"
                    :height 110)

;; Package management
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Get use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;; evil
(use-package evil
  :ensure t
  :init
  (setq evil-search-module'evil-search)
  (setq evil-ex-complete-emacs-commands nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-shift-round nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode)
  ;; Set up leader key (defvar leader-map
  (defvar leader-map (make-sparse-keymap) "Keymap for leader key")
  (define-key evil-normal-state-map "," leader-map)
  (define-key leader-map "w" 'evil-window-vsplit)
  (define-key leader-map "h" 'evil-window-split)
  (define-key leader-map "b" 'ibuffer)
  ;; Rebind ctrl-p
  (define-key evil-normal-state-map (kbd "C-p") #'projectile-find-file))

(use-package evil-commentary
  :ensure t
  :after evil
  :init
  (evil-commentary-mode))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))

;; Doom themes
(use-package doom-themes
  :ensure t
  :init
  (setq doom-themes-enable-bold t)
  (setq doom-themes-enable-italic nil)
  :config
  (load-theme 'doom-one t)
  (load-user-file "modeline.el")
  (set-face-attribute 'whitespace-tab nil :background "inherit")
  (set-face-attribute 'show-paren-match nil :weight 'bold :foreground (doom-color 'cyan))
  (set-face-attribute 'line-number nil :foreground (doom-color 'fg-alt)))

;; Vertical ido
(use-package ido-vertical-mode
  :ensure t
  :init
  (setq ido-enable-flex-matching t)
  (setq ido-vertical-define-keys 'C-n-and-C-p-only)
  :config
  (ido-mode 1)
  (ido-vertical-mode 1))

(use-package flx-ido
  :ensure t
  :after ido-vertical-mode
  :config
  (setq ido-use-faces nil)
  :init
  (ido-everywhere 1)
  (flx-ido-mode 1))

(use-package idomenu
  :ensure t
  :bind ("C-S-o" . idomenu))

;; Projectile
(use-package projectile
  :ensure t
  :init
  (setq projectile-require-project-root nil)
  :config
  (projectile-mode +1)
  (define-key leader-map "p" 'projectile-command-map))

(use-package ripgrep
  :ensure t)

(use-package swoop
  :ensure t
  :config
  (define-key leader-map "s" 'swoop)
  (set-face-attribute 'swoop-face-target-line nil
                      :foreground (doom-color 'fg)
                      :background (doom-color 'bg-alt))
  (set-face-attribute 'swoop-face-target-words nil
                      :weight 'bold
                      :foreground (doom-color 'bg)
                      :background (doom-color 'violet))
  (set-face-attribute 'swoop-face-header-format-line nil
                      :height 110
                      :foreground (doom-color 'fg))
  (set-face-attribute 'swoop-face-line-buffer-name nil
                      :height 110
                      :foreground (doom-color 'blue)
                      :background (doom-color 'bg-alt))
  (set-face-attribute 'swoop-face-line-number nil
                      :foreground (doom-color 'orange)))

(use-package treemacs
  :ensure t
  :after doom-themes
  :init
  (setq treemacs-width 20)
  (setq treemacs-no-png-images t)
  :config
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode t)
  (treemacs-git-mode 'deferred)
  (set-face-attribute 'treemacs-directory-face nil :foreground (doom-color 'fg))
  (set-face-attribute 'treemacs-term-node-face nil :foreground (doom-color 'blue) :weight 'bold)
  (set-face-attribute 'treemacs-git-modified-face nil :foreground (doom-color 'yellow))
  (set-face-attribute 'treemacs-git-untracked-face nil :foreground (doom-color 'green))
  (set-face-attribute 'treemacs-root-face nil
                      :height 110
                      :weight 'normal
                      :foreground (doom-color 'cyan))
  (define-key leader-map "t" treemacs-mode-map)
  (define-key leader-map "n" 'treemacs)
  (define-key leader-map "a" 'treemacs-add-and-display-current-project))

(use-package treemacs-evil
  :after treemacs evil
  :ensure t)

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package flycheck
  :ensure t
  :after doom-themes
  :config
  (add-hook 'typescript-mode-hook 'flycheck-mode)
  (global-flycheck-mode)
  (setq flycheck-check-syntax-automatically '(mode-enabled save))
  (setq flycheck-indication-mode 'right-fringe)

  (define-key leader-map "f" flycheck-command-map)
  (global-set-key (kbd "<f8>") 'flycheck-next-error)
  (global-set-key (kbd "S-<f8>") 'flycheck-previous-error)

  (set-face-attribute 'flycheck-fringe-info nil
                      :foreground (doom-color 'bg)
                      :background (doom-color 'bg))
  (set-face-attribute 'flycheck-fringe-warning nil
                      :foreground (doom-color 'orange)
                      :background (doom-color 'orange))
  (set-face-attribute 'flycheck-fringe-error nil
                      :foreground (doom-color 'red)
                      :background (doom-color 'red)))

(use-package company
  :ensure t
  :config
  (setq company-frontends '(company-preview-frontend company-echo-frontend))
  (setq company-minimum-prefix-length 1)
  (setq company-idle-delay 1)
  (define-key company-active-map (kbd "<return>") #'company-complete-selection)
  (define-key company-active-map (kbd "<tab>") #'company-complete-selection)
  :init
  (add-hook 'after-init-hook 'global-company-mode))

(use-package company-lsp
  :ensure t
  :after company
  :config
  (push 'company-lsp company-backends))

(use-package which-key
  :ensure t
  :init
  (which-key-mode 1))

(use-package git-gutter-fringe
  :ensure t
  :after doom-themes
  :config
  (global-git-gutter-mode)
    (fringe-helper-define 'git-gutter-fr:deleted nil
      "........."
      "........."
      "........."
      "........."
      "........."
      "XXXXXXXXX"
      "XXXXXXXXX"
      "XXXXXXXXX"
      "XXXXXXXXX"
      "XXXXXXXXX"
      ".........")

    (set-face-attribute 'git-gutter-fr:modified nil
                        :foreground (doom-color 'blue)
                        :background (doom-color 'blue))
    (set-face-attribute 'git-gutter-fr:added nil
                        :foreground (doom-color 'green)
                        :background (doom-color 'green))
    (set-face-attribute 'git-gutter-fr:deleted nil
                        :foreground (doom-color 'red)))

(use-package magit
  :ensure t)

;; lsp
(use-package lsp-mode
  :ensure t
  :config
  (setq lsp-enable-completion-at-point t)
  (setq lsp-prefer-flymake nil)
  (setq lsp-auto-guess-root t)
  :commands lsp)

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-sideline-enable nil)
  (setq lsp-ui-doc-enable nil)
  ; Doesn't work, idk
  (setq lsp-ui-imenu-colors '(repeat (doom-color 'blue) (doom-color 'green)))
  (define-key leader-map "l" 'lsp-ui-imenu)
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))

(load-language "go")
(go/init-go-mode)

(load-language "rust")
(rust/init-rust-mode)

(load-language "haskell")
(haskell/init-haskell-mode)

(load-language "typescript")
(typescript/init-web-mode)
(typescript/init-tide-mode)

