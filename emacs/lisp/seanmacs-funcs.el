;;; seanmacs-funcs.el --- Funcs -*- lexical-binding: t; -*-

;;; Commentary:
;; Useful funcs.
;;
;; TODO: Use lexical binding, ido-goto-symbol breaks when lexical binding is
;; enabled.

;;; Code:

(core/leader
 "ci" 'seanmacs/indent-buffer)

(core/leader
 "br" 'seanmacs/rename-buffer-special
 "bv" 'revert-buffer
 "bk" 'kill-this-buffer)

(defun seanmacs/rename-buffer-special (newname)
  "Rename buffer to NEWNAME, wrapping NEWNAME in '*' characters when original name has them."
  (interactive (list (read-string "Rename buffer (to new name): ")))
  (let ((newname (if (string-prefix-p "*" (buffer-name))
                     (format "*%s*" newname)
                   newname)))
    (rename-buffer newname t)))

(defun seanmacs/indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(provide 'seanmacs-funcs)
;;; seanmacs-funcs.el ends here
