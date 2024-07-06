;;; nginx-mode-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from nginx-mode.el

(autoload 'nginx-mode "nginx-mode" "\
Major mode for highlighting nginx config files.

The variable nginx-indent-level controls the amount of indentation.
\\{nginx-mode-map}

(fn)" t)
(add-to-list 'auto-mode-alist '("nginx\\.conf\\'" . nginx-mode))
(add-to-list 'auto-mode-alist '("/nginx/.+\\.conf\\'" . nginx-mode))
(add-to-list 'magic-fallback-mode-alist '("\\(?:.*
\\)*\\(?:http\\|server\\|location .+\\|upstream .+\\)[ 
	]+{" . nginx-mode))
(register-definition-prefixes "nginx-mode" '("nginx-"))

;;; End of scraped data

(provide 'nginx-mode-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; nginx-mode-autoloads.el ends here