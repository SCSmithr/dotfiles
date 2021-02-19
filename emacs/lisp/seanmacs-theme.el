;;; seanmacs-theme.el --- Theme -*- lexical-binding: t; -*-

;;; Commentary:
;; Theme stuff.

;;; Code:

(defun face-attr (face &rest args)
  (apply #'set-face-attribute face nil args))

(defun reset-face (face)
  (apply #'face-spec-reset-face face nil))

;; Set fonts.
(add-to-list 'default-frame-alist `(font . "Fira Mono-11"))
(face-attr 'variable-pitch :weight 'light :family "Fira Sans" :height 130)

(use-package minions
  :straight t
  :config
  (setq minions-direct '(flycheck-mode))

  (minions-mode 1))

(defvar sm/load-theme-hook nil
  "Hook run after a color theme is loaded using `load-theme'.")

(defun sm/run-load-theme-hook (&rest _)
  "Run after `sm/load-theme-hook'."
  (run-hooks 'sm/load-theme-hook))

(advice-add #'load-theme :after #'sm/run-load-theme-hook)

(use-package modus-operandi-theme
  :straight t
  :config
  (setq modus-operandi-theme-links 'faint
        modus-operandi-theme-diffs 'desaturated
        modus-operandi-theme-section-headings nil
        modus-operandi-theme-scale-headings nil
        modus-operandi-theme-headings nil
        modus-operandi-theme-org-blocks 'greyscale
        modus-operandi-theme-fringes 'subtle)

  (setq x-underline-at-descent-line t)

  (setq modus-operandi-theme-override-colors-alist
        '(("fg-main"                 . "#26272d")
          ("bg-main"                 . "#fcfcfc")
          ("fg-alt"                  . "#808080")
          ("bg-region"               . "#dfdfdf")
          ("fg-whitespace"           . "#dadada")
          ("bg-whitespace"           . "#fcfcfc")
          ("fg-window-divider-inner" . "#dadada")
          ("fg-window-divider-outer" . "#aaaaaa")))

  (defun sm/customize-modus-operandi ()
    (modus-operandi-theme-with-color-variables
      (face-attr 'success :foreground green :weight 'normal)
      (face-attr 'warning :foreground yellow :weight 'normal)
      (face-attr 'error :foreground red :weight 'normal)
      (face-attr 'region :background bg-region :foreground 'unspecified)

      (custom-theme-set-faces
       'modus-operandi
       ;; Whitespace
       `(whitespace-hspace ((t (:foreground ,fg-whitespace))))
       `(whitespace-indentation ((t (:foreground ,fg-whitespace))))
       `(whitespace-line ((t (:background ,bg-dim))))
       `(whitespace-newline ((t (:foreground ,fg-whitespace))))
       `(whitespace-space ((t (:foreground ,fg-whitespace))))
       `(whitespace-tab ((t (:foreground ,fg-whitespace))))
       ;; Extend highlights
       `(mu4e-header-highlight-face ((t (:inherit modus-theme-hl-line :extend t))))
       ;; Company
       `(company-preview ((t (:inherit (modus-theme-nuanced-magenta) :foreground ,magenta))))
       `(company-preview-common ((t (:inherit (modus-theme-nuanced-blue) :foreground ,blue))))
       ;; Eshell
       `(eshell-ls-directory ((t (:foreground ,blue-alt)))))))

  (add-hook 'sm/load-theme-hook 'sm/customize-modus-operandi)
  (load-theme 'modus-operandi t))

(provide 'seanmacs-theme)
;;; seanmacs-theme.el ends here
