;;; keybinds.el --- Core keybindings -*- lexical-binding: t; -*-

(defvar core-leader-map (make-sparse-keymap)
  "Base keymap for all leader key commands.")

(defun core/set-leader-keys (key def &rest bindings)
  (while key
    (define-key core-leader-map (kbd key) def)
    (setq key (pop bindings) def (pop bindings))))

(defalias 'core/leader 'core/set-leader-keys)

(defun core/set-leader-major-mode-keys (mode key def &rest bindings)
  (let* ((hook (intern (format "%s-hook" mode))))
    (add-hook hook
              (lambda ()
                (defvar mode-map (make-sparse-keymap))
                (core/set-leader-keys "m" mode-map)
                (while key
                  (define-key mode-map (kbd key) def)
                  (setq key (pop bindings) def (pop bindings)))))))

(defalias 'core/local 'core/set-leader-major-mode-keys)

(provide 'keybinds)
;;; keybinds.el ends here
