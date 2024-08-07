;;; minitest-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from minitest.el

(autoload 'minitest-mode "minitest" "\
Minor mode for *_test (minitest) files

This is a minor mode.  If called interactively, toggle the
`Minitest mode' mode.  If the prefix argument is positive, enable
the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `minitest-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

\\{minitest-mode-map}

(fn &optional ARG)" t)
(autoload 'minitest-toggle-test-and-target "minitest" "\
Switch to the test or the target file for the current buffer.
If the current buffer is visiting a test file, switches to the
target, otherwise the test." t)
(autoload 'minitest-enable-appropriate-mode "minitest")
(dolist (hook '(ruby-mode-hook enh-ruby-mode-hook)) (add-hook hook 'minitest-enable-appropriate-mode))
(register-definition-prefixes "minitest" '("colorize-compilation-buffer" "minitest-"))

;;; End of scraped data

(provide 'minitest-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; minitest-autoloads.el ends here
