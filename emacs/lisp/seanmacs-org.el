;;; seanmacs-org.el --- Org -*- lexical-binding: t; -*-

;;; Commentary:
;; Org configuration.

;;; Code:

(use-package org
  :defer t
  :config
  (setq org-default-notes-file "~/syncthing/notes/refile.org"
        org-agenda-files (list "~/syncthing/notes/")
        org-agenda-restore-windows-after-quit t
        org-agenda-span 'fortnight
        org-agenda-window-setup 'current-window
        org-refile-targets '((org-agenda-files :maxlevel . 3))
        org-template-directory "~/.emacs.d/org-templates"
        org-startup-folded nil
        org-hide-leading-stars t
        org-blank-before-new-entry (quote ((heading . always) (plain-list-item . always)))
        org-enforce-todo-dependencies t)

  (plist-put org-format-latex-options :scale 1.4)

  (setq org-capture-templates
        `(
          ("n" "Note" entry (file+headline "" "Notes")
           (file ,(concat org-template-directory "/note"))
           :empty-lines 1)
          ("t" "Task" entry (file+headline "" "Tasks")
           (file ,(concat org-template-directory "/task"))
           :empty-lines 1)))

  (setq org-todo-keywords
        '((sequence "TODO" "IN-PROGRESS" "|" "DONE" "CANCELED"))))

(use-package org-agenda
  :defer t
  :bind (:map org-agenda-mode-map
              ("j" . evil-next-line)
              ("k" . evil-previous-line)))

(use-package ob
  ;; built-in
  :after org
  :config
  (require 'ob-http)
  (require 'gnuplot)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell      . t)
     (js         . t)
     (emacs-lisp . t)
     (lisp       . t)
     (haskell    . t)
     (sql        . t)
     (http       . t)
     (gnuplot    . t)
     (calc       . t)
     (python     . t)))
  (add-hook 'org-babel-after-execute-hook 'org-display-inline-images))

(use-package ob-http
  :straight t
  :defer t)

(use-package gnuplot
  :straight t
  :defer t)

(provide 'seanmacs-org)
;;; seanmacs-org.el ends here
