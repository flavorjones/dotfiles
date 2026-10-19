;;; packages.el --- install missing packages -*- lexical-binding: t -*-

;; init.el loads this, and so does omarchy-recipe in batch mode:
;;   emacs --batch -l ~/.config/emacs/packages.el
;; The batch run installs everything before the daemon starts, because the
;; first install can take longer than systemd's start timeout. In batch mode a
;; failure is an error. At startup it is a warning, so init.el goes on, but
;; it still stops at the first `require' of a package that is missing.

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq custom-file (expand-file-name "custom-file.el" user-emacs-directory))
(load custom-file)

(defun my-missing-packages ()
  (seq-remove #'package-installed-p package-selected-packages))

(condition-case err
    (when (my-missing-packages)
      (package-refresh-contents)
      (package-install-selected-packages t)
      (when (my-missing-packages)
        (error "Packages not installed: %S" (my-missing-packages))))
  (error
   (if noninteractive
       (signal (car err) (cdr err))
     (display-warning 'packages (error-message-string err)))))

;;; packages.el ends here
