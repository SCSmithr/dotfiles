;;; seanmacs-shell.el --- Shell -*- lexical-binding: t -*-

;;; Commentary:
;; Configurations for shell and eshell

;;; Code:

(require 'subr-x)

(defun sm/compile (command &optional buf-name)
  "Run COMMAND in a compilation buffer named BUF-NAME.

If BUF-NAME is nil, the command will be used to name the buffer."
  (interactive (list (compilation-read-command "")))
  (let ((compilation-buffer-name-function
         #'(lambda (_mode) (or buf-name (format "*Compile: %s*" command)))))
    (compile command)))

(defun sm/listify-env-vars (env val &rest rest)
  "Create a list of environment variables and values suitable to use in the shell."
  (let ((list '()))
    (while env
      (let ((s (format "%s=%s" env val)))
        (push s list))
      (setq env (pop rest) val (pop rest)))
    list))

(defun sm/append-process-environment (env val &rest rest)
  (append (apply 'sm/listify-env-vars env val rest) process-environment '()))

(use-package compile
  ;; built-in
  :init
  (require 'ansi-color)
  (defun sm/colorize-compile-buffer ()
    (ansi-color-apply-on-region compilation-filter-start (point)))
  :hook ((compilation-filter . sm/colorize-compile-buffer)))

(defun sm/disable-company ()
  (company-mode -1))

(use-package shrink-path
  :straight t
  :commands (shrink-path-prompt))

(defvar sm/eshell-append-history-on-command t
  "Whether or not eshell should write to the history file before each command.")

(defun sm/shrink-path-prompt (path)
  "Shrink PATH, preserving tramp related strings."
  (if (file-remote-p path)
      (let* ((tramp-file (tramp-dissect-file-name path))
             (method (tramp-file-name-method tramp-file))
             (user (tramp-file-name-user tramp-file))
             (host (tramp-file-name-host tramp-file))
             (localname (tramp-file-name-localname tramp-file))
             (shrunk (shrink-path-prompt localname))
             (prompt-host (if user
                              (string-join `(,user ,host) "@")
                            host))
             (prompt-base (string-join `(,method ,prompt-host ,(car shrunk)) ":")))
        (cons prompt-base (cdr shrunk)))
    (shrink-path-prompt path)))

(use-package eshell
  ;; built-in
  :init
  (defun sm/add-eshell-aliases ()
    ;; Shell command aliases. I'd rather not keep track of the eshell
    ;; aliases file.
    (dolist (alias '(("cargo" "cargo --color=always $*")
                     ;; kubectl
                     ("kgp" "kubectl get pods $*")
                     ("kgs" "kubectl get service $*")
                     ("kgn" "kubectl get namespace $*")
                     ("kdp" "kubectl delete pod $*")
                     ("ksn" "kubectl config set-context --current --namespace=$1")
                     ("kcn" "kubectl config view --minify --output 'jsonpath={..namespace}'; echo")
                     ("kl" "kubectl logs $* --all-containers")))
      (add-to-list 'eshell-command-aliases-list alias)))

  (defun sm/eshell-append-history ()
    "Append the most recent command in eshell's history ring to history file."
    (when (and eshell-history-ring
               sm/eshell-append-history-on-command)
      (let ((newest-cmd-ring (make-ring 1)))
        (ring-insert newest-cmd-ring (car (ring-elements eshell-history-ring)))
        (let ((eshell-history-ring newest-cmd-ring))
          (eshell-write-history eshell-history-file-name t)))))

  :config
  (defface sm/eshell-prompt-pwd '((t :inherit eshell-ls-directory))
    "Face for current directory."
    :group 'eshell)

  (defface sm/eshell-prompt-short-pwd '((t :inherit font-lock-comment-face))
    "Face for shortened path."
    :group 'eshell)

  (defface sm/eshell-prompt-git-branch '((t :inherit font-lock-builtin-face))
    "Face for displaying current git branch."
    :group 'eshell)

  (defface sm/eshell-prompt-success '((t :inherit eshell-prompt))
    "Face when previous command succeeds."
    :group 'eshell)

  (defface sm/eshell-prompt-error '((t :inherit error :weight normal))
    "Face when previous command fails."
    :group 'eshell)

  (defun sm/eshell-current-git-branch ()
    (let ((branch (car (cl-loop for match in (split-string (shell-command-to-string "git branch") "\n")
                                if (string-match-p "^\*" match)
                                collect match))))
      (if (not (eq branch nil))
          (format " %s" (substring branch 2))
        "")))

  (defun sm/eshell-default-prompt ()
    "Generate the prompt string for eshell.  Use for `eshell-prompt-function'."
    (let ((shrunk-dir (sm/shrink-path-prompt default-directory)))
      (concat (propertize (car shrunk-dir)
                          'face 'sm/eshell-prompt-short-pwd)
              (propertize (cdr shrunk-dir)
                          'face 'sm/eshell-prompt-pwd)
              (propertize (sm/eshell-current-git-branch)
                          'face 'sm/eshell-prompt-git-branch)
              (propertize " $" 'face (if (zerop eshell-last-command-status)
                                         'sm/eshell-prompt-success
                                       'sm/eshell-prompt-error))
              ;; Needed for the input text to not have prompt face.
              (propertize " " 'face 'default))))

  (defun sm/eshell-new ()
    (interactive)
    (eshell "new"))

  (defalias 'eshell/ff 'find-file)

  (defun eshell/d (&optional path)
    (dired (or path ".")))

  (defun eshell/mkcd (path)
    (let ((args (list "-p" path)))
      (eshell/mkdir args)
      (eshell/cd path)))

  (defun eshell/pd ()
    (if (projectile-project-p)
        (eshell/cd (projectile-project-root))
      (user-error "Not in project")))

  (defun eshell/clear ()
    "Clear the eshell buffer."
    (let ((inhibit-read-only t))
      (erase-buffer)
      (eshell-send-input)))

  (defun sm/eshell-insert (&rest args)
    (goto-char (point-max))
    ;; Only reset prompt if there's already some input.
    (let ((curr-point (point)))
      (eshell-bol)
      (let ((no-input (eq (- curr-point (point)) 0)))
        (unless no-input
          (eshell-reset))))
    (evil-insert 1)
    (apply 'insert args))

  (defun eshell/read-history ()
    (interactive)
    (eshell-read-history)
    (sm/eshell-insert (completing-read
                       "History: "
                       (mapcar #'string-trim
                               (delete-dups
                                (ring-elements eshell-history-ring))))))

  (setq eshell-history-size 10000
        eshell-save-history-on-exit nil ;; This is handled elsewhere.
        eshell-cmpl-cycle-completions nil
        eshell-prompt-function #'sm/eshell-default-prompt
        eshell-prompt-regexp "^.* \\$ ")

  (add-hook 'eshell-mode-hook
            (lambda ()
              ;; Needs to be ran inside the hook since eshell-mode-map is
              ;; buffer local.
              ;;
              ;; See https://github.com/noctuid/general.el/issues/80
              (local-set-key (kbd "C-c h") 'eshell/read-history)))

  ;; Expand !<n> and !!
  (add-hook 'eshell-expand-input-functions #'eshell-expand-history-references)

  :hook ((eshell-mode . sm/add-eshell-aliases)
         (eshell-mode . sm/disable-company)
         (eshell-pre-command . sm/eshell-append-history))
  :bind (("C-c s s" . eshell)
         ("C-c s n" . sm/eshell-new)
         :map eshell-mode-map
         ;; Defaulted to `eshell-complete-lisp-symbol'.
         ("M-<tab>" . completion-at-point)))

(use-package shell
  ;; built-in
  :config
  :hook ((shell-mode . sm/disable-company)))

(provide 'seanmacs-shell)
;;; seanmacs-shell.el ends here

