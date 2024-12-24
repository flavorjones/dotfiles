(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-delay 0.5)
 '(ac-trigger-key "")
 '(auto-dark-mode t)
 '(auto-dark-themes '((solarized-dark) (solarized-light)))
 '(browse-url-temp-dir "/home/flavorjones/tmp")
 '(create-lockfiles nil)
 '(custom-safe-themes
   '("c7fd1708e08544d1df2cba59b85bd25263180b19b287489d4f17b9118487e718" "c71fd8fbda070ff5462e052d8be87423e50d0f437fbc359a5c732f4a4c535c43" "833ddce3314a4e28411edf3c6efde468f6f2616fc31e17a62587d6a9255f4633" "78e6be576f4a526d212d5f9a8798e5706990216e9be10174e3f3b015b8662e27" "41c478598f93d62f46ec0ef9fbf351a02012e8651e2a0786e0f85e6ac598f599" "4c56af497ddf0e30f65a7232a8ee21b3d62a8c332c6b268c81e9ea99b11da0d3" "fee7287586b17efbfda432f05539b58e86e059e78006ce9237b8732fde991b4c" "830877f4aab227556548dc0a28bf395d0abe0e3a0ab95455731c9ea5ab5fe4e1" "c433c87bd4b64b8ba9890e8ed64597ea0f8eb0396f4c9a9e01bd20a04d15d358" "2809bcb77ad21312897b541134981282dc455ccd7c14d74cc333b6e549b824f3" "a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" default))
 '(dired-listing-switches "-alG")
 '(dired-use-ls-dired t)
 '(electric-pair-pairs '((34 . 34) (8216 . 8217) (8220 . 8221) (96 . 96)))
 '(electric-pair-text-pairs '((34 . 34) (8216 . 8217) (8220 . 8221) (96 . 96)))
 '(fill-column 100)
 '(frame-inhibit-implied-resize t)
 '(frame-resize-pixelwise t)
 '(fringe-mode nil nil (fringe))
 '(git-link-open-in-browser t)
 '(global-goto-address-mode t)
 '(global-undo-tree-mode t)
 '(goto-address-fontify-p nil)
 '(goto-address-highlight-p nil)
 '(highlight-indent-guides-method 'character)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(initial-major-mode 'gfm-mode)
 '(initial-scratch-message "# scratch buffer\12")
 '(ispell-highlight-face 'flyspell-incorrect)
 '(js2-auto-indent-flag nil)
 '(js2-enter-indents-newline nil)
 '(js2-mirror-mode nil)
 '(js2-mode-indent-ignore-first-tab t)
 '(markdown-fontify-code-blocks-natively t)
 '(markdown-link-space-sub-char "-")
 '(markdown-wiki-link-search-subdirectories t)
 '(neo-autorefresh t)
 '(neo-keymap-style 'concise)
 '(neo-smart-open t)
 '(neo-theme 'arrow)
 '(neo-window-fixed-size nil)
 '(org-agenda-files '("~/docs/notes/todo.org"))
 '(org-file-apps
   '(("txt" . emacs)
     ("tex" . emacs)
     ("ltx" . emacs)
     ("org" . emacs)
     ("el" . emacs)
     ("bib" . emacs)
     ("pdf" . "evince '%s'")))
 '(org-hide-leading-stars t)
 '(org-log-done 'time)
 '(org-odd-levels-only t)
 '(org-startup-folded 'content)
 '(package-selected-packages
   '(auto-dark swift-mode sort-words mise windsize diminish ligature zig-mode which-key minitest rust-mode lsp-ui lsp-mode nginx-mode copilot quelpa-use-package quelpa monokai-theme night-owl-theme atomic-chrome protobuf-mode bison-mode git-link poly-ruby polymode hide-mode-line projectile-rails edit-indirect editorconfig rubocopfmt interaction-log bazel-mode ivy json-mode projectile nix-mode auto-compile crystal-mode csharp-mode direnv dockerfile-mode elm-mode exec-path-from-shell feature-mode go-mode haml-mode hl-todo julia-mode lua-mode magit markdown-toc neotree powershell rspec-mode ruby-hash-syntax sass-mode use-package yaml-mode markdown-mode udev-mode bicycle web-mode solarized-theme gnu-elpa-keyring-update ruby-additional ruby-end ruby-refactor rvm slim-mode toml-mode unicode-fonts markdown-mode+ go-autocomplete go-snippets golint gitattributes-mode gitconfig-mode gitignore-mode flymake-ruby rufo flycheck-julia undo-tree rnc-mode org minimap git-blame css-mode auto-highlight-symbol))
 '(paradox-github-token t)
 '(pixel-scroll-mode t)
 '(pixel-scroll-precision-mode t)
 '(projectile-rails-global-mode t)
 '(remote-file-name-inhibit-locks t)
 '(ring-bell-function 'ignore)
 '(rubocopfmt-use-bundler-when-possible nil)
 '(ruby-align-to-stmt-keywords t)
 '(ruby-flymake-use-rubocop-if-available nil)
 '(safe-local-variable-values
   '((frozen_string_literal . true)
     (eval c-set-offset 'inlambda 0)
     (eval c-set-offset 'access-label '-)
     (eval c-set-offset 'substatement-open 0)
     (eval c-set-offset 'arglist-cont-nonempty '+)
     (eval c-set-offset 'arglist-cont 0)
     (eval c-set-offset 'arglist-intro '+)
     (eval c-set-offset 'inline-open 0)
     (eval c-set-offset 'defun-open 0)
     (eval c-set-offset 'innamespace 0)
     (indicate-empty-lines . t)
     (whitespace-line-column . 80)
     (eval when
           (fboundp 'rainbow-mode)
           (rainbow-mode 1))
     (require-final-newline . t)
     (mangle-whitespace . t)
     (encoding . utf-8)
     (ruby-compilation-executable . "ruby")
     (ruby-compilation-executable . "ruby1.8")
     (ruby-compilation-executable . "ruby1.9")
     (ruby-compilation-executable . "rbx")
     (ruby-compilation-executable . "jruby")))
 '(sh-basic-offset 2)
 '(solarized-scale-org-headlines nil)
 '(solarized-use-variable-pitch nil)
 '(undo-tree-visualizer-diff t)
 '(undo-tree-visualizer-timestamps t)
 '(visual-line-fringe-indicators '(nil right-curly-arrow))
 '(web-mode-code-indent-offset 2)
 '(web-mode-css-indent-offset 2)
 '(web-mode-enable-auto-indentation nil)
 '(web-mode-markup-indent-offset 2)
 '(web-mode-sql-indent-offset 2)
 '(web-mode-tests-directory "~/tests/"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(copilot-overlay-face ((t (:inherit (shadow highlight italic))))))
