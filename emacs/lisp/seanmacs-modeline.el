;;; seanmacs-modeline.el --- Modeline -*- lexical-binding: t; -*-

;;; Commentary:
;; Modeline configuration.

;;; Code:

(defgroup modeline nil
  "A minimal modeline configuration inspired by doom-modeline."
  :group 'modeline)

(defface modeline-status-mode
  `((t (:inherit (font-lock-keyword-face))))
  "Face used for mode indicators in the modeline."
  :group 'modeline)

(defface modeline-status-vc
  `((t (:inherit (font-lock-builtin-face))))
  "Face used for vc indicators in the modeline."
  :group 'modeline)

(defface modeline-status-success
  `((t (:inherit (success))))
  "Face used for success status indicators in the modeline."
  :group 'modeline)

(defface modeline-status-warning
  '((t (:inherit (warning))))
  "Face for warning status indicators in the modeline."
  :group 'modeline)

(defface modeline-status-error
  '((t (:inherit (error))))
  "Face for error stauts indicators in the modeline."
  :group 'modeline)

(defun modeline-format (left right)
  (let ((reserve (length right)))
    (when (and (display-graphic-p) (eq 'right (get-scroll-bar-mode)))
      (setq reserve (- reserve 3)))
    (concat
     left
     " "
     (propertize " "
                 'display `((space :align-to (- (+ right right-margin) ,(+ reserve 0)))))
     right)))

;; Window update function
(defvar-local modeline--current-window (frame-selected-window))
(defun modeline--update-selected-window (&rest _)
  "Update the `modeline--current-window' variable."
  (when (frame-selected-window)
    (let ((win (frame-selected-window)))
      (unless (minibuffer-window-active-p win)
        (setq modeline--current-window win)))))

;; VC update function
(defvar-local modeline--vc-text nil)
(defun modeline--update-vc-segment (&rest _)
  "Update `modeline--vc-text' against the current VCS state."
  (setq modeline--vc-text
        (when (and vc-mode buffer-file-name)
          (let ((backend (vc-backend buffer-file-name))
                (state (vc-state buffer-file-name (vc-backend buffer-file-name))))
            (substring vc-mode (+ (if (eq backend 'Hg) 2 3) 2))))))

;; Flycheck update function
(defvar-local modeline--flycheck-text nil)
(defun modeline--update-flycheck-segment (&optional status)
  "Update `modeline--flycheck-text' against the reported flycheck STATUS."
  (setq modeline--flycheck-text
        (pcase status
          (`finished (let-alist (flycheck-count-errors flycheck-current-errors)
                       (let ((error (or .error 0))
                             (warning (or .warning 0))
                             (info (or .info 0)))
                         (format "%s/%s/%s "
                                 (if (> error 0)
                                     (propertize (number-to-string error) 'face 'modeline-status-error)
                                   (number-to-string error))
                                 (if (> warning 0)
                                     (propertize (number-to-string warning) 'face 'modeline-status-warning)
                                   (number-to-string warning))
                                 (if (> info 0)
                                     (propertize (number-to-string info) 'face 'modeline-status-success)
                                   (number-to-string info))))))
          ('running "-/-/- ")
          ('no-checker "")
          ('errored (propertize "!!! " 'face 'modeline-status-error))
          ('interrupted "--- "))))

(defun modeline-segment-modified-or-readonly ()
  "Displays a color-coded buffer modification or readonly
indicator in the modeline."
  (cond (buffer-read-only
         "R ")
        ((buffer-modified-p)
         "U ")
        (t "  ")))

(defun modeline-segment-buffer-name ()
  "Displays the name of the current buffer in the modeline."
  (propertize "%b " 'face 'mode-line-buffer-id))

(defun modeline-segment-dir ()
  "Display shortened working directory."
  (shrink-path-dirs default-directory))

(defun modeline-segment-position ()
  "Displays the current cursor position in the modeline."
  (let ((fmt-string " %3l:%2c "))
    fmt-string))

(defun modeline-segment-buffer-percent ()
  "Displays the percentage of buffer above current point."
  (let ((fmt-string "%p%% "))
    fmt-string))

(defun modeline-segment-vc ()
  "Displays color-coded version control information in the modeline."
  (when modeline--vc-text
    (propertize modeline--vc-text 'face 'modeline-status-vc)))

(defun modeline-segment-major-mode ()
  "Displays the current major mode in the modeline."
  (propertize " %m" 'face 'modeline-status-mode))

(defun modeline-segment-flycheck ()
  "Displays color-coded flycheck information in the modeline (if available)."
  modeline--flycheck-text)

(defun modeline-segment-process ()
  "Displays the current value of `mode-line-process' in the modeline."
  (when mode-line-process
    (list mode-line-process)))

;;;###autoload
(define-minor-mode modeline-mode
  "Toggle modeline on or off."
  :group 'modeline
  :global t
  :lighter nil
  (if modeline-mode
      (progn

        ;; Setup flycheck hooks
        (add-hook 'flycheck-status-changed-functions #'modeline--update-flycheck-segment)
        (add-hook 'flycheck-mode-hook #'modeline--update-flycheck-segment)

        ;; Setup VC hooks
        (add-hook 'find-file-hook #'modeline--update-vc-segment)
        (add-hook 'after-save-hook #'modeline--update-vc-segment)
        (advice-add #'vc-refresh-state :after #'modeline--update-vc-segment)

        ;; Setup window update hooks
        (add-hook 'window-configuration-change-hook #'modeline--update-selected-window)
        (add-hook 'focus-in-hook #'modeline--update-selected-window)
        (advice-add #'handle-switch-frame :after #'modeline--update-selected-window)
        (advice-add #'select-window :after #'modeline--update-selected-window)

        ;; Set the new modeline-format
        (setq-default mode-line-format
                      '((:eval
                         (modeline-format
                          ;; Left
                          (format-mode-line
                           '((:eval (modeline-segment-position))
                             (:eval (modeline-segment-modified-or-readonly))
                             (:eval (modeline-segment-dir))
                             (:eval (modeline-segment-buffer-name))
                             (:eval (modeline-segment-buffer-percent))))

                          ;; Right
                          (format-mode-line
                           '((:eval (modeline-segment-flycheck))
                             (:eval (modeline-segment-vc))
                             (:eval (modeline-segment-major-mode))
                             (:eval (modeline-segment-process))
                             " ")))))))
    (progn

      ;; Remove flycheck hooks
      (remove-hook 'flycheck-status-changed-functions #'modeline--update-flycheck-segment)
      (remove-hook 'flycheck-mode-hook #'modeline--update-flycheck-segment)

      ;; Remove VC hooks
      (remove-hook 'file-find-hook #'modeline--update-vc-segment)
      (remove-hook 'after-save-hook #'modeline--update-vc-segment)
      (advice-remove #'vc-refresh-state #'modeline--update-vc-segment)

      ;; Remove window update hooks
      (remove-hook 'window-configuration-change-hook #'modeline--update-selected-window)
      (remove-hook 'focus-in-hook #'modeline--update-selected-window)
      (advice-remove #'handle-switch-frame #'modeline--update-selected-window)
      (advice-remove #'select-window #'modeline--update-selected-window)

      ;; Restore the original modeline format
      (setq-default modeline-format modeline--default-modeline))))

(provide 'seanmacs-modeline)
;;; seanmacs-modeline.el ends here

