;;; init.el --- Init -*- lexical-binding: t; -*-

;;; Commentary:
;; Emacs configuration.

;;; Code:

;; Hide some things.
;; Do this first so that I never see the menu bar.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; GC things
(setq gc-cons-threshold 20000000)
(setq read-process-output-max (* 1024 1024))

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
 )

;; Get straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Ensure use-package is here.
(straight-use-package 'use-package)

(defun seanmacs/run-and-bury (fn &rest args)
  "Run FN with ARGS then bury the buffer."
  (let ((buf (buffer-name)))
    (apply fn args)
    (bury-buffer buf)))

(use-package seanmacs-keybinds
  :load-path "lisp"
  :config
  (core/init-leader))

(use-package seanmacs-theme
  :load-path "lisp")

(use-package seanmacs-windows
  :load-path "lisp")

(use-package seanmacs-edit
  :load-path "lisp")

(use-package seanmacs-completions
  :load-path "lisp")

(use-package seanmacs-utils
  :load-path "lisp")

(use-package seanmacs-version-control
  :load-path "lisp")

(use-package seanmacs-org
  :load-path "lisp")

(use-package seanmacs-modeline
  :load-path "lisp"
  :config
  (modeline-mode))

(use-package seanmacs-langs
  :load-path "lisp")

(use-package seanmacs-shell
  :load-path "lisp")

(use-package seanmacs-email
  :load-path "lisp")

;;; init.el ends here
