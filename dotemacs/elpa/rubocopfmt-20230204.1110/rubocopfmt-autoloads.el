;;; rubocopfmt-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "rubocopfmt" "rubocopfmt.el" (0 0 0 0))
;;; Generated autoloads from rubocopfmt.el

(autoload 'rubocopfmt "rubocopfmt" "\
Format the current buffer with rubocop." t nil)

(autoload 'rubocopfmt-mode "rubocopfmt" "\
Enable format-on-save for `ruby-mode' buffers via rubocopfmt.

This is a minor mode.  If called interactively, toggle the
`Rubocopfmt mode' mode.  If the prefix argument is positive,
enable the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `rubocopfmt-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

\(fn &optional ARG)" t nil)

(register-definition-prefixes "rubocopfmt" '("rubocopfmt-"))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; rubocopfmt-autoloads.el ends here
