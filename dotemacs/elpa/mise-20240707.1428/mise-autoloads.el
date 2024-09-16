;;; mise-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from mise.el

(autoload 'mise-mode "mise" "\
A local minor mode in which env vars are set by mise.

This is a minor mode.  If called interactively, toggle the `Mise
mode' mode.  If the prefix argument is positive, enable the mode,
and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `mise-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

(fn &optional ARG)" t)
(put 'global-mise-mode 'globalized-minor-mode t)
(defvar global-mise-mode nil "\
Non-nil if Global Mise mode is enabled.
See the `global-mise-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `global-mise-mode'.")
(custom-autoload 'global-mise-mode "mise" nil)
(autoload 'global-mise-mode "mise" "\
Toggle Mise mode in all buffers.
With prefix ARG, enable Global Mise mode if ARG is positive; otherwise, disable it.

If called from Lisp, toggle the mode if ARG is `toggle'.
Enable the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

Mise mode is enabled in all buffers where `mise-turn-on-if-enable' would do it.

See `mise-mode' for more information on Mise mode.

(fn &optional ARG)" t)
(register-definition-prefixes "mise" '("mise-"))

;;; End of scraped data

(provide 'mise-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; mise-autoloads.el ends here
