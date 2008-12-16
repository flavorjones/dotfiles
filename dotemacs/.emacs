;;;;;;;;;; -*- emacs-lisp -*-
;;;  emacs init file
;;;;;;;;;;
;;;
;;;  for blocks executed conditionally based on emacs version number
;;;
(defun requires-emacs-version (at-least function)
  (if (>= emacs-major-version at-least)
      (funcall function)))


;;;
;;;  our external resources
;;;
(setq load-path (append '("~/.emacs.d") load-path))

;;;;;;;;;;
;;;  color themes and font-lock mode setup
;;;;;;;;;;
(cond (window-system
       (require 'color-theme)
       (load "color-theme-vivid-chalk")
       (color-theme-vivid-chalk)
       ))

 (add-hook 'font-lock-mode-hook
           '(lambda ()
              (unless (string-equal "org-mode" major-mode)
                ;; in order, match one-line '[TODO ... ]', two-line '[TODO ...\n ... ]'
                ;; then one-line 'TODO ...'
                (font-lock-add-keywords
                 nil ;; mode name
                 '(("\\[\\(XXX\\|TODO\\|FIXME\\).*\\]\\|\\[\\(XXX\\|TODO\\|FIXME\\).*
 ?.*\\]\\|\\(XXX\\|TODO\\|FIXME\\).*$"
                    0 font-lock-warning-face t)))
              )))

;;;;;;;;;;
;;; general variables, functions
;;;;;;;;;;
(line-number-mode t)
(transient-mark-mode t)
(setq default-major-mode 'text-mode)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(display-time)
(set-input-mode nil nil t)       ; so we can use ALT as a META key (?)
(setq-default indent-tabs-mode nil)
(when window-system
  ;; enable wheelmouse support by default
  (mwheel-install))
;;; turn off all the decorations and gui-helpful bullshit
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
;; but i like the scrollbar. having an analog indicator of position in a buffer is good.
(set-scroll-bar-mode 'right)
(global-font-lock-mode t)
(menu-bar-enable-clipboard)
(ido-mode)
(set-fill-column 100) ;; yay widescreen
(auto-compression-mode 1) ;; allow opening of .gz (et al) files directly

(setq max-specpdl-size 1000000) ;; for byte-compiling js2-mode and mumamo-do-fontify
(setq max-lisp-eval-depth 10000) ;; for mumamo-do-fontify (!?)

;; save desktop only when in windowing mode, to avoid getting prompted for
;; saving by 'emacs -nw', which is what my EDITOR envvar is set to (which
;; is used by git, svn, etc.)
(when window-system (desktop-save-mode 1))

;;;;;;;;;;
;;;  miscellaneous file types linked to modes
;;;;;;;;;;
(setq auto-mode-alist (append '(("\\.mxml$" . xml-mode)
                                ("\\.html$" . html-mode)
                                ("\\.css$" . css-mode)
                                ("\\.xml$" . xml-mode)
                                ("\\.markdown$" . markdown-mode)
                                ("\\.mdml$" . markdown-mode)
                                ("\\.as$" . java-mode)) ; actionscript
                              auto-mode-alist))
(setq auto-mode-alist
      (append '(("\\.c$"  . c-mode)     ; to edit C code
		("\\.h$"  . c-mode)     ; to edit C code
		("\\.ec$" . c-mode)
		("\\.php$" . c-mode)
		) auto-mode-alist))
(setq auto-mode-alist
      (append
       '(("\\.cpp\\'" . c++-mode))
       '(("\\.h\\'" . c++-mode))
       '(("\\.inl\\'" . c++-mode))
       '(("\\.dox\\'" . c++-mode))
       auto-mode-alist))
(setq auto-mode-alist
      (append
       '(("\\.cmake\\'" . cmake-mode))
       '(("CMakeLists\\.txt\\'" . cmake-mode))
       auto-mode-alist))
(setq auto-mode-alist
      (append
       '(("\\.rb$" . ruby-mode)
         ("\\.cap$" . ruby-mode)
         ("\\.rake$" . ruby-mode))
       auto-mode-alist))
(setq auto-mode-alist (cons '("\\.F$" . fortran-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.hf$" . fortran-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.inc$" . fortran-mode) auto-mode-alist))
(add-to-list 'auto-mode-alist '("\\.gob\\'" . c-mode))
(setq auto-mode-alist (append (list (cons "\\.pl$" 'perl-mode))
                              auto-mode-alist))
(setq auto-mode-alist (append '(("\\.el$" . emacs-lisp-mode)
                                ("\\.cl$" . lisp-mode)
                                ("\\.lisp$" . lisp-mode))
                              auto-mode-alist))

;;;;;;;;;;
;;;  some random stuff.
;;;;;;;;;;
(autoload 'ediff "ediff" nil t)         ;  cool diff mode
(autoload 'flame "flame" nil t)         ;  automated flaming

;;;;;;;;;;
;;;  minibuffer resizes dynamically
;;;;;;;;;;
(autoload 'resize-minibuffer-mode "rsz-mini" nil t)
(resize-minibuffer-mode)

;;;;;;;;;;
;;; key bindings
;;;;;;;;;;
(global-set-key "\C-x\C-w" 'kill-rectangle)
(global-set-key "\C-x\C-y" 'yank-rectangle)
(global-set-key "\C-cg" 'goto-line)
(global-set-key "\C-cr" 'replace-regexp)
(global-set-key "\er" 'query-replace-regexp)
(global-set-key "\C-c\C-a" 'auto-fill-mode)
                                        ; (global-set-key "\C-cd" 'spell-buffer)
                                        ; (global-set-key "\C-cj" 'justify-current-line)
(global-set-key "\C-cj" 'join-line)
(global-set-key "\C-c\t" 'tab-to-tab-stop)
(global-set-key "\C-x\C-q" 'toggle-read-only)
(global-set-key "\C-co" 'my-find-other-file)
(global-set-key [\C-tab] 'yic-next-buffer)
(global-set-key [\S-tab] 'yic-prev-buffer)

;;;
;;; frame-related bindings
;;;
(global-set-key "\C-c\C-fo" 'other-frame)
(global-set-key "\C-c\C-fn" 'new-frame)
(global-set-key "\C-c\C-fd" 'delete-frame)
(global-set-key "\C-c\C-fs" 'speedbar)

(global-set-key "\C-c;" 'comment-or-uncomment-region)

;;;
;;;  these so we can resize buffer windows using the mouse
;;;
(require 'mldrag)
(global-set-key [mode-line down-mouse-1] 'mldrag-drag-mode-line)
(global-set-key [vertical-line down-mouse-1] 'mldrag-drag-vertical-line)
(global-set-key [vertical-scroll-bar S-down-mouse-1] 'mldrag-drag-vertical-line)

;;  prepend or replace a cons cell with given key
(defun my-unique-prepend (key val assoc)
  "Returns a copy of assoc with cons cell (key . val)."
  (let ((CELL (assq key assoc)))
    (cond ((consp CELL) (setcdr CELL val))
          ((push '(key . val) assoc)))))

;;;;;;;;;;
;;;  text-mode
;;;;;;;;;;
(add-hook 'text-mode-hook
          (function
           (lambda ()
             (local-set-key "\C-c\C-l" 'longlines-mode)
             )))

;;;
;;;  markdown-mode
;;;
(add-hook 'markdown-mode-hook
          (function
           (lambda ()
             (local-set-key "\C-c\C-l" 'longlines-mode)
             )))

;;;;;;;;;;
;;;  common c modes
;;;;;;;;;;
(add-hook 'c-mode-common-hook
          (function
           (lambda ()

;;; shall we use tabs or spaces? t is tabs, nil is spaces.
             (setq indent-tabs-mode nil) ;;; nil forces spaces always
;;; set tabbing convention and display
             (c-set-style "stroustrup")
             (setq c-basic-offset 2)
;;; make inline function definitions indent like i want
             (let ((CELL (assq 'inline-open c-offsets-alist)))
               (cond ((consp CELL) (setcdr CELL 0))
                     ((push '(inline-open . 0) c-offsets-alist))))
             (let ((CELL (assq 'inher-intro c-offsets-alist)))
               (cond ((consp CELL) (setcdr CELL 0))
                     ((push '(inher-intro . 0) c-offsets-alist))))

             (auto-fill-mode)
             (set-fill-column 80)

             ;; c++-style comments
             (fset 'my-cpp-comment-wide
		   [?\C-o tab ?/ ?/ escape ?9 ?* return tab ?/ ?/
                          return tab ?/ ?/ escape ?9 ?* ?\C-p ?  ? ])
             (fset 'my-cpp-comment
		   [?\C-o tab ?/ ?/ return tab ?/ ?/ return tab ?/ ?/
                          ?\C-p ?  ? ])
             ;; c-style comments
             (fset 'my-c-comment-wide
		   [?\C-o tab ?/ escape ?1 ?0 ?* return ?* tab
                          return escape ?1 ?0 ?* ?/ ?\C-p ?  ? ])
             (fset 'my-c-comment
		   [?\C-o tab ?/ ?* return ?* tab return ?* ?/
                          ?\C-p ?  ? ])

             (fset 'my-c-dox-comment
		   [?\C-o tab ?/ ?* ?* return ?* tab return ?*
                          ?/ ?\C-p ?  ? ])
             (local-set-key "\C-c\C-v" 'my-c-dox-comment)

;;; to override c-electric-star
             (local-set-key "*" 'self-insert-command )

             (hs-minor-mode 1)

             )))

;;;;;;;;;;
;;; cc-mode (c-mode)
;;;;;;;;;;
(add-hook 'c-mode-hook
          (function
           (lambda ()
             (local-set-key "\C-cc" 'my-c-comment-wide)
             (local-set-key "\C-cv" 'my-c-comment))))

;;;;;;;;;;
;;;  c++-mode
;;;;;;;;;;
(add-hook 'c++-mode-hook
          (function
           (lambda ()
             (local-set-key "\C-cc" 'my-cpp-comment-wide)
             (local-set-key "\C-cv" 'my-cpp-comment))))


;;;;;;;;;;
;;;  cmake-mode
;;;;;;;;;;
(add-hook 'cmake-mode-hook
          (function
           (lambda ()
             ;;
             ;; this rocking one-line command makes '_' a word delimiter
             ;; just like in cc-mode
             ;;
             (modify-syntax-entry ?_  "_" )

             (fset 'my-perl-comment
		   [15 32 escape 49 48 35 tab return 32 35 tab return
                       32 escape 49 48 35 tab 16 32 32])
             (fset 'my-perl-comment2
		   (read-kbd-macro
                    "C-o TAB # RET TAB # RET TAB # C-p C-e 2*SPC"))
             (local-set-key "\C-cc" 'my-perl-comment)
             (local-set-key "\C-cv" 'my-perl-comment2)
             )))


;;;;;;;;;;
;;;  ruby-mode
;;;;;;;;;;
;;;
;;;  http://www.emacswiki.org/cgi-bin/wiki/FlymakeRuby
;;;
(require 'flymake)
(defun flymake-ruby-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (list "ruby" (list "-c" local-file))))
(push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
(push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)
(push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3) flymake-err-line-patterns)
(add-hook 'ruby-mode-hook
          (function
           (lambda ()
             (fset 'my-ruby-comment
		   [?\C-o tab escape ?1 ?0 ?# return tab ?# ?  ?  return tab escape ?1 ?0 ?# ?\C-p])
             (fset 'my-ruby-comment2
		   [?\C-o tab ?# return tab ?# ?  ?  return tab ?# ?\C-p ?\C-e])
             (local-set-key "\C-cc" 'my-ruby-comment)
             (local-set-key "\C-cv" 'my-ruby-comment2)
             (setq case-fold-search t) ;; this should be in ruby-mode, imho.
             (local-set-key "\t" 'indent-for-tab-command) ;; this should be in ruby-mode, imho.
             (setq ruby-electric-expand-delimiters-list nil)

             ;; Don't want flymake mode for ruby regions in rhtml files and also on read only files
             (if (and (not (null buffer-file-name)) (file-writable-p buffer-file-name))
                 (flymake-mode))
             )))

;;;;;;;;;;
;;;  sql-mode
;;;;;;;;;;
(add-hook 'sql-mode-hook
          (function
           (lambda ()
             (fset 'my-sql-comment
		   [?\C-o tab escape ?1 ?0 ?- return tab ?- ?- ?- ?  ?  return tab escape ?1 ?0 ?- ?\C-p])
             (fset 'my-sql-comment2
		   [?\C-o tab ?- ?- ?- return tab ?- ?- ?- ?  ?  return tab ?- ?- ?- ?\C-p ?\C-e])
             (local-set-key "\C-cc" 'my-sql-comment)
             (local-set-key "\C-cv" 'my-sql-comment2)
             )))

;;;;;;;;;;
;;;  java mode
;;;;;;;;;;
(add-hook 'java-mode-hook
          (function
           (lambda ()
             (local-set-key "\C-cc" 'my-cpp-comment-wide)
             (local-set-key "\C-cv" 'my-cpp-comment))))


;;;;;;;;;;
;;;  fortran mode
;;;;;;;;;;
(setq fortran-mode-hook
      '(lambda ()
         (fortran-auto-fill-mode 72)
         (abbrev-mode t)
         (setq
          fortran-comment-region "c"
          fortran-comment-indent-style 'relative
          fortran-blink-matching-if t
          fortran-do-indent 2
          fortran-if-indent 2
          fortran-structure-indent 2
          fortran-comment-line-extra-indent -2
          fortran-continuation-indent 5
          fortran-continuation-string ".")
         (fset 'fortranchow
               [67 32 32 32 67 104 111 119 32 114 117 108 101 115 return 42 tab escape 49 48 42])
         (fset 'my-fortran-comment1
               [15 escape 49 48 42 return 42 return escape 49 48 42 16
		   32 32])
         (fset 'my-fortran-comment2
               [15 42 32 escape 49 48 42 tab return 42 32 42 tab
		   return 42 32 escape 49 48 42 tab 16 32 32])
         (local-set-key "\C-cp" 'fortranchow)
         (local-set-key "\C-cc" 'my-fortran-comment1)
         (local-set-key "\C-cv" 'my-fortran-comment2)
;;;        (cond (window-system
;;;               (setq hilit-mode-enable-list  '(fortran-mode)
;;;                     hilit-background-mode   'light
;;;                     hilit-auto-highlight    t
;;;                     hilit-inhibit-hooks     nil
;;;                     hilit-inhibit-rebinding nil)
;;;               (require 'hilit19)
;;;               ))

         ;;
         ;; this rocking one-line command makes '_' a word delimiter
         ;; just like in cc-mode
         ;;
         (modify-syntax-entry ?_  "_" )

         ))


;;;;;;;;;;
;;; perl-mode
;;;;;;;;;;
(autoload 'perl-mode "perl-mode" "Perl mode." t)
(add-hook 'perl-mode-hook
          (function
           (lambda ()
             (setq
              perl-tab-to-comment nil
              perl-indent-level 2
              perl-continued-brace-offset -2
              perl-label-offset 0
              )
             (fset 'my-perl-comment
		   [15 32 escape 49 48 35 tab return 32 35 tab return
                       32 escape 49 48 35 tab 16 32 32])
             (fset 'my-perl-comment2
		   (read-kbd-macro
                    "C-o TAB # RET TAB # RET TAB # C-p C-e 2*SPC"))
             (local-set-key "\C-cc" 'my-perl-comment)
             (local-set-key "\C-cv" 'my-perl-comment2)
             )))

;;;;;;;;;;
;;;  sh-mode
;;;;;;;;;;
(add-hook 'sh-mode-hook
          (function
           (lambda ()
             (fset 'my-sh-comment
		   [?# return ?# return ?# return ?\C-p ?\C-p ?\C-e ?  ? ])
             (local-set-key "\C-cv" 'my-sh-comment)
             )))


;;;;;;;;;;
;;;  mail mode
;;;;;;;;;;
(autoload 'mail-comment-region "mailfunc" "" t)
(autoload 'mail-yank-and-comment-original "mailfunc" "" t)
(add-hook 'mail-mode-hook
          (function
           (lambda ()
             (local-set-key "\C-i" "     ")
             (local-set-key "\C-c;" 'mail-comment-region)
             (local-set-key "\C-c\C-y" 'mail-yank-and-comment-original)
             (auto-fill-mode)
             (setq mail-self-blind t)
             (setq mail-default-reply-to "mike@csa.net")
             )))

;;;;;;;;;;
;;;  rmail mode
;;;;;;;;;;
(add-hook 'rmail-mode-hook
          (function
           (lambda ()
             (setq
              next-screen-context-lines 5
              )
             )))
(setq rmail-file-name "~/.rmail/incoming")
(setq rmail-last-rmail-file "~/.rmail/received")
(setq rmail-default-rmail-file "~/.rmail/received")
(setq rmail-primary-inbox-list
      (append rmail-primary-inbox-list
              (list "~/.rmail/MBOX" )
              ))


;;;;;;;;;;
;;;  lisps
;;;;;;;;;;
(defun my-lisp-mode-hook ()
  (fset 'my-lisp-comment
        [15 escape 49 48 59 return 59 59 59 return escape
            49 48 59 16 32 32])
  (fset 'my-lisp-comment2
        [?\C-o tab ?\; ?\; ?\; return tab ?\; ?\; ?\; return tab ?\; ?\; ?\; ?\C-p ?  ? ])
  (local-set-key "\C-cc" 'my-lisp-comment)
  (local-set-key "\C-cv" 'my-lisp-comment2)
  )
(add-hook 'emacs-lisp-mode-hook
          (function my-lisp-mode-hook))
(add-hook 'lisp-mode-hook
          (function my-lisp-mode-hook))

;;;;;;;;;;
;;;  outline mode
;;;;;;;;;;
(add-hook 'outline-mode-hook
          (function
           (lambda ()
             (hide-body)             ; hide everything except headings
             )))

;;;;;;;;;;
;;;  hideshow mode
;;;;;;;;;;
(add-hook 'hs-minor-mode-hook
          (function
           (lambda ()
             (setq hs-hide-comments-when-hiding-all nil)
             (setq hs-isearch-open t)
             (setq hs-show-hidden-short-form nil)
             (local-set-key "\C-cl" 'hs-hide-level)
             )))

;;;;;;;;;;
;;;  scheme mode
;;;;;;;;;;
(add-hook 'scheme-mode-hook
          (function
           (lambda ()
             (fset 'my-scheme-comment
                   [15 escape 49 48 59 return 59 59 59 return escape
                       49 48 59 16 32 32])
             (local-set-key "\C-cc" 'my-scheme-comment)
             )))

;;;;;;;;;;
;;;  tex mode
;;;;;;;;;;
(add-hook 'tex-mode-hook
          (function
           (lambda ()
             (setq tex-dvi-view-command "xdvi")
             (fset 'my-tex-comment-wide
                   [?\C-o tab ?% escape ?9 ?* return tab ?%
                          return tab ?% escape ?9 ?* ?\C-p ?  ? ])
             (fset 'my-tex-comment
                   [?\C-o tab ?% return tab ?% return tab ?%
                          ?\C-p ?  ? ])
             (local-set-key "\C-cc" 'my-tex-comment-wide)
             (local-set-key "\C-cv" 'my-tex-comment)
             )))


;;;;;;;;;;
;;;  latex mode
;;;;;;;;;;
(add-hook 'latex-mode-hook
          (function
           (lambda ()
             (setq tex-command "pdflatex")
             )))

;;;;;;;;;;
;;;  html mode
;;;;;;;;;;
(add-hook 'html-mode-hook
          (function (lambda ()
                      (local-set-key "\C-c\C-i" 'indent-relative) ;; for embedded js
                      )))

;;;;;;;;;;
;;;  longlines (emacs 22 and up)
;;;;;;;;;;
(autoload 'longlines-mode
  "longlines.el"
  "Minor mode for automatically wrapping long lines." t)

;;;;;;;;;;
;;;  my ruler
;;;;;;;;;;
(defvar my-column-ruler
  (concat
   "        10        20        30        40"
   "        50        60        70        80        90       100\n"
   "    +    |    +    |    +    |    +    |\n"
   "    +    |    +    |    +    |    +    |    +    |    +    |\n")
  "*String displayed above current line by \\[my-column-ruler].")

(defun my-column-ruler ()
  "Inserts a column ruler momentarily above current line, till next keystroke.
The ruler is defined by the value of my-column-ruler.
The key typed is executed unless it is SPC."
  (interactive)
  (momentary-string-display
   my-column-ruler (save-excursion (beginning-of-line) (point))
   nil "Type SPC or any command to erase ruler."))

(global-set-key "\C-c\C-r" 'my-column-ruler)


;;;;;;;;;;
;;;  these in case I am on an XON/OFF or really, really dumb terminal
;;;;;;;;;;
;(global-set-key "\C-cs" 'isearch-forward-regexp)
;(global-set-key "\C-\\" 'isearch-repeat-forward-regexp)
;(global-set-key "\C-c\C-c " 'set-mark-command)

;;;;;;;;;;
;;;  my-find-other-file is intended to help browse lots of source files
;;;  my-load-if-exists is a helper function
;;;;;;;;;;
(defun my-load-if-exists (list)
  (cond (list
         (cond ((file-exists-p (car list))
                (find-file-other-window (car list)))
               ((my-load-if-exists (cdr list)))))
        ((error "Could not find a matching file."))))

(defun my-find-other-file ()
  "Given a source code file, will load the header file into a new buffer."
  (interactive)
  (let ((curbuf (buffer-name)))
    (cond ((string-match "\.cpp$" curbuf)
           (my-load-if-exists (list (replace-match ".h" t t curbuf))))
          ((string-match "\.c$" curbuf)
           (my-load-if-exists (list (replace-match ".h" t t curbuf))))
          ((string-match "\.inl$" curbuf)
           (my-load-if-exists (list (replace-match ".h" t t curbuf))))
          ((string-match "\.h$" curbuf)
           (my-load-if-exists (list (replace-match ".cpp" t t curbuf)
                                    (replace-match ".c" t t curbuf)
                                    (replace-match ".inl" t t curbuf)))
           ))))


;;;;;;;;;;
;;;  ripped off from yaroslav
;;;;;;;;;;
(defun yic-ignore (str)
  (or
   ;;buffers I don't want to switch to
   (string-match "\\*Buffer List\\*" str)
   (string-match "^TAGS" str)
   (string-match "^\\*Messages\\*$" str)
   (string-match "^\\*Completions\\*$" str)
   (string-match "^ " str)

   ;;Test to see if the window is visible on an existing visible frame.
   ;;Because I can always ALT-TAB to that visible frame, I never want to
   ;;Ctrl-TAB to that buffer in the current frame.  That would cause
   ;;a duplicate top-level buffer inside two frames.
   (memq str
         (mapcar
          (lambda (x)
            (buffer-name
             (window-buffer
              (frame-selected-window x))))
          (visible-frame-list)))
   ))

(defun yic-next (ls)
  "Switch to next buffer in ls skipping unwanted ones."
  (let* ((ptr ls)
         bf bn go
         )
    (while (and ptr (null go))
      (setq bf (car ptr)  bn (buffer-name bf))
      (if (null (yic-ignore bn))        ;skip over
          (setq go bf)
        (setq ptr (cdr ptr))
        )
      )
    (if go
        (switch-to-buffer go))))

(defun yic-prev-buffer ()
  "Switch to previous buffer in current window."
  (interactive)
  (yic-next (reverse (buffer-list))))

(defun yic-next-buffer ()
  "Switch to the other buffer (2nd in list-buffer) in current window."
  (interactive)
  (bury-buffer (current-buffer))
  (yic-next (buffer-list)))


;;;;;;;;;;
;;;  some nice font shit
;;;;;;;;;;
(defun what-font ()
  (interactive)
  (message (frame-parameter nil 'font)))

(requires-emacs-version 23
                        '(lambda ()
                           (setq mike:font-face nil)
                           (setq mike:font-size nil)

                           (defun mike:set-font-face (face)
                             (interactive)
                             (setq mike:font-face face)
                             (mike:enact-font))

                           (defun mike:set-font-size (size)
                             (interactive)
                             (setq mike:font-size size)
                             (mike:enact-font))

                           (defun mike:enact-font ()
                             (if (and mike:font-face mike:font-size)
                                 (let* ((font (concat mike:font-face "-" (number-to-string mike:font-size))))
                                   (set-default-font font)
                                   (prin1 font))))

                           (defun mike:modify-font-size (increment)
                             (setq mike:font-size (+ mike:font-size increment))
                             (mike:enact-font))

                           (defun mike:increase-font-size ()
                             (interactive)
                             (mike:modify-font-size 1))
    
                           (defun mike:decrease-font-size ()
                             (interactive)
                             (mike:modify-font-size -1))
    
                           (global-set-key [?\C-=] 'mike:increase-font-size)
                           (global-set-key [?\C-+] 'mike:increase-font-size)
                           (global-set-key [?\C--] 'mike:decrease-font-size)
    
                           (mike:set-font-size 10)
                           (mike:set-font-face "Bitstream Vera Sans Mono")
;;;                            (mike:set-font-size 9)
;;;                            (mike:set-font-face "Bitstream Vera Sans")

                           ))

;;;
;;;  camelCase
;;;
(autoload 'camelCase-mode "camelCase-mode" nil t)
(add-hook 'find-file-hook '(lambda () (camelCase-mode 1))) ; all files. (all buffers?)

;;;
;;;  emacs ruby on rails mode
;;;
;; (setq load-path (cons "~/.emacs.d/emacs-rails" load-path))
;; (require 'rails)
;; (add-hook 'ruby-mode-hook '(lambda () (menu-bar-mode 1)))

;;;  latest ruby-mode
(add-to-list 'load-path "~/.emacs.d/ruby-mode")
(require 'ruby-mode)
(require 'ruby-electric)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode t)))

;;;  rinari
(add-to-list 'load-path "~/.emacs.d/rinari")
(require 'rinari)
(global-set-key (kbd "C-x C-M-f") 'find-file-in-project) ;; optional
(setq rinari-tags-file-name "TAGS")

;;; rhtml
(add-to-list 'load-path "~/.emacs.d/rhtml")
(require 'rhtml-mode)
(add-hook 'rhtml-mode-hook
     	  (lambda () (rinari-launch)))
(add-to-list 'auto-mode-alist '("\\.html\\.erb$" . rhtml-mode))

;;; nxml (HTML ERB template support)
;; (load "~/.emacs.d/nxhtml/autostart.el")
     
;; (setq
;;  nxhtml-global-minor-mode t
;;  mumamo-chunk-coloring 'submode-colored
;;  nxhtml-skip-welcome t
;;  indent-region-mode t
;;  rng-nxml-auto-validate-flag nil
;;  nxml-degraded t)
;; (add-to-list 'auto-mode-alist '("\\.html\\.erb\\'" . eruby-nxhtml-mumamo))

;;; yasnippet
(require 'yasnippet-bundle)
(yas/initialize)
(yas/load-directory "~/.emacs.d/yasnippets-rails/rails-snippets")

;;;
;;;  yegge's js2 mode
;;;
(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-hook 'js2-mode-hook
          (function
           (lambda ()
             (fset 'my-cpp-comment-wide
                   [?\C-o tab ?/ ?/ escape ?9 ?* return tab ?/ ?/
                          return tab ?/ ?/ escape ?9 ?* ?\C-p ?  ? ])
             (fset 'my-cpp-comment
                   [?\C-o tab ?/ ?/ return tab ?/ ?/ return tab ?/ ?/
                          ?\C-p ?  ? ])
             (local-set-key "\C-cc" 'my-cpp-comment-wide)
             (local-set-key "\C-cv" 'my-cpp-comment)
             )))

;;; pastie
(load "pastie.el")

;;;
;;;  org-mode
;;;
(global-set-key "\C-ca" 'org-agenda)
(add-hook 'org-mode-hook
          '(lambda ()
             ; set the org-mode-map to override any and all minor modes, because there are
             ; critical collisions with camelCase mode (M-right, M-left).
             (setq minor-mode-overriding-map-alist (list (cons t (copy-keymap org-mode-map))))
             ))

;;;
;;;  let's get ansi color support in shell
;;;
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;;;
;;;  git support
;;;
;; (setq load-path (cons (expand-file-name "/usr/share/doc/git-core/contrib/emacs") load-path))
;; (require 'vc-git)
;; (when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
;; (require 'git)
;; (autoload 'git-blame-mode "git-blame"
;;   "Minor mode for incremental blame for Git." t)

;;; "she bangs, she bangs." -William Hung
(require 'shebang)

;;;  i loves me some emacs server.
(server-start)

;;;  let's try global-auto-revert in case i need to pair program
(global-auto-revert-mode 1)

;;;
;;;  customize!
;;;
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ido-case-fold nil)
 '(ido-confirm-unique-completion t)
 '(ido-enable-dot-prefix t)
 '(ido-enable-flex-matching t)
 '(inhibit-startup-screen t)
 '(js2-auto-indent-flag nil)
 '(js2-enter-indents-newline nil)
 '(js2-mirror-mode nil)
 '(js2-mode-indent-ignore-first-tab t)
 '(org-agenda-files (quote ("~/docs/notes/todo.org" "~/docs/notes/deep_data.org")))
 '(org-drawers (quote ("PROPERTIES" "CLOCK" "CODE")))
 '(org-file-apps (quote (("txt" . emacs) ("tex" . emacs) ("ltx" . emacs) ("org" . emacs) ("el" . emacs) ("bib" . emacs) ("pdf" . "evince '%s'"))))
 '(org-hide-leading-stars t)
 '(org-log-done (quote time))
 '(org-odd-levels-only t)
 '(org-startup-folded (quote content))
 '(org-todo-keywords (quote ((sequence "TODO" "NEXT" "WAITING" "SOMEDAY" "DONE")))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

(put 'narrow-to-region 'disabled nil)
