;;; zig-mode-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from zig-mode.el

(autoload 'zig-compile "zig-mode" "\
Compile using `zig build`." t)
(autoload 'zig-build-exe "zig-mode" "\
Create executable from source or object file." t)
(autoload 'zig-build-lib "zig-mode" "\
Create library from source or assembly." t)
(autoload 'zig-build-obj "zig-mode" "\
Create object from source or assembly." t)
(autoload 'zig-test-buffer "zig-mode" "\
Test buffer using `zig test`." t)
(autoload 'zig-run "zig-mode" "\
Create an executable from the current buffer and run it immediately." t)
 (autoload 'zig-format-buffer "current-file" nil t)
 (autoload 'zig-format-region "current-file" nil t)
 (autoload 'zig-format-on-save-mode "current-file" nil t)
(autoload 'zig-mode "zig-mode" "\
A major mode for the Zig programming language.

\\{zig-mode-map}

(fn)" t)
(add-to-list 'auto-mode-alist '("\\.\\(zig\\|zon\\)\\'" . zig-mode))
(register-definition-prefixes "zig-mode" '("zig-"))

;;; End of scraped data

(provide 'zig-mode-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; zig-mode-autoloads.el ends here
