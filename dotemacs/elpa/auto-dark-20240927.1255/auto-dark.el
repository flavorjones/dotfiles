;;; auto-dark.el --- Automatically sets the dark-mode theme based on macOS/Linux/Windows status -*- lexical-binding: t; -*-

;; Author: Rahul M. Juliato
;;         Tim Harper <timcharper at gmail dot com>
;;         Vincent Zhang <seagle0128@gmail.com>
;;         Jonathan Arnett <jonathan.arnett@protonmail.com>
;;         Greg Pfeil <greg@technomadic.org>
;; Created: July 16 2019
;; Package-Version: 20240927.1255
;; Package-Revision: 117e20cddf17
;; Keywords: macos, windows, linux, themes, tools, faces
;; URL: https://github.com/LionyxML/auto-dark-emacs
;; Package-Requires: ((emacs "24.4"))
;; SPDX-License-Identifier: GPL-2.0-or-later

;;; Commentary:
;; Auto-Dark is an auto-changer between 2 themes, dark/light, respecting the
;; overall settings of MacOS, Linux and Windows.
;; To enable it, install the package and add it to your load path:
;;
;;     (require 'auto-dark)
;;     (auto-dark-mode t)
;;
;; To customize the themes used by light/dark mode:
;;
;;     M-x customize-group auto-dark
;;
;; If you're using Doom Emacs or Spacemacs, follow the installation tips
;; on https://github.com/LionyxML/auto-dark-emacs.
;;

;;; Code:

;; Optional require of dbus squelches elisp compilation warnings
(require 'dbus nil t)

(defgroup auto-dark nil
  "Automatically changes Emacs theme acording to MacOS/Windows dark-mode status."
  :group 'tools
  :prefix "auto-dark-*")

;; Dark & light themes need to be set together because enabling and disabling
;; themes modifies `custom-enabled-themes', so if only one mode were expected to
;; default to `custom-enabled-themes', it would use the wrong list of themes
;; after the first time the other mode enables its themes.
(defcustom auto-dark-themes nil
  "The themes to enable for dark and light modes.
The default is to use the themes in `custom-enabled-themes', but that only works
if the themes are aware of `frame-background-mode', which many aren’t.

If your themes aren’t aware of `frame-background-mode' (or you just prefer
different themes for dark and light modes), you can set explicit lists of themes
for each mode. Like with `custom-enabled-themes', the earlier themes in the list
have higher precedence."
  :group 'auto-dark
  :type '(choice
          (const :tag "Use custom-enabled-themes" nil)
          (list :tag "Use distinct dark & light lists"
                (repeat :tag "Dark" symbol)
                (repeat :tag "Light" symbol))))

(defcustom auto-dark-dark-theme 'wombat
  "The theme to enable when dark-mode is active.

This variable is obsolete. You should set `auto-dark-themes' instead."
  :group 'auto-dark
  :type '(choice symbol (const nil)))

(defcustom auto-dark-light-theme 'leuven
  "The theme to enable when dark-mode is inactive.

This variable is obsolete. You should set `auto-dark-themes' instead."
  :group 'auto-dark
  :type '(choice symbol (const nil)))

(make-obsolete-variable 'auto-dark-dark-theme 'auto-dark-themes "0.13")
(make-obsolete-variable 'auto-dark-light-theme 'auto-dark-themes "0.13")

(defun auto-dark--patch-theme-list (themes deprecated-theme)
  "Support the deprecated ‘auto-dark-*-theme’ variables.
If THEMES is non-nil, it’s simply returned. If ‘custom-enabled-themes’ isn’t
set, a list containing only DEPRECATED-THEME is returned, otherwise nil.

Once the deprecated variables are removed “(auto-dark--patch-theme-list a b)”
can be replaced by “a”."
  (or themes
      (unless (and custom-enabled-themes
                   (not (equal custom-enabled-themes
                               (list auto-dark-dark-theme)))
                   (not (equal custom-enabled-themes
                               (list auto-dark-light-theme))))
        (when deprecated-theme (list deprecated-theme)))))

(defun auto-dark--dark-themes ()
  "Return the set of themes to be used in dark mode."
  (auto-dark--patch-theme-list (car auto-dark-themes) auto-dark-dark-theme))

(defun auto-dark--light-themes ()
  "Return the set of themes to be used in light mode."
  (auto-dark--patch-theme-list (cadr auto-dark-themes) auto-dark-light-theme))

(defcustom auto-dark-polling-interval-seconds 5
  "The number of seconds between which to poll for dark mode state.
Emacs must be restarted for this value to take effect."
  :group 'auto-dark
  :type 'integer)

(defcustom auto-dark-allow-osascript nil
  "Whether to allow function `auto-dark-mode' to shell out to osascript:
to check dark-mode state, if `ns-do-applescript' or `mac-do-applescript'
is not available."
  :group 'auto-dark
  :type 'boolean)

(defcustom auto-dark-allow-powershell nil
  "Whether to allow function `auto-dark-mode' to shell out to powershell:
to check dark-mode state."
  :group 'auto-dark
  :type 'boolean)

(defcustom auto-dark-detection-method nil
  "The method auto-dark should use to detect the system theme.

Defaults to nil and will be populated through feature detection
if left as such.  Only change this value if you know what you're
doing!"
  :group 'auto-dark
  :type 'symbol
  :options '(applescript osascript dbus powershell winreg termux))

(defvar auto-dark--last-dark-mode-state 'unknown)

(defvar auto-dark--dbus-listener-object nil)

(defun auto-dark--is-dark-mode-applescript ()
  "Invoke AppleScript using Emacs built-in AppleScript support.
In order to check if dark mode is enabled.  Return true if it is."
  (if (fboundp 'ns-do-applescript)
      (auto-dark--is-dark-mode-ns)
    (if (fboundp 'mac-do-applescript)
        (auto-dark--is-dark-mode-mac)
      (error "No AppleScript support available in this Emacs build.  Try setting `auto-dark-allow-osascript` to t"))))

(defun auto-dark--is-dark-mode-ns ()
  "Check if dark mode is enabled using ns-do-applescript."
  (string-equal "true" (ns-do-applescript "tell application \"System Events\"
        tell appearance preferences
                if (dark mode) then
                        return \"true\"
                else
                        return \"false\"
                end if
        end tell
end tell")))

(defun auto-dark--is-dark-mode-mac ()
  "Check if dark mode is enabled using `mac-do-applescript'."
  (string-equal "\"true\"" (mac-do-applescript "tell application \"System Events\"
        tell appearance preferences
                if (dark mode) then
                        return \"true\"
                else
                        return \"false\"
                end if
        end tell
end tell")))


(defun auto-dark--is-dark-mode-osascript ()
  "Invoke applescript using Emacs using external shell command;
this is less efficient, but works for non-GUI Emacs."
  (string-equal "true" (string-trim (shell-command-to-string "osascript -e 'tell application \"System Events\" to tell appearance preferences to return dark mode'"))))

(defun auto-dark--is-dark-mode-dbus ()
  "Use Emacs built-in D-Bus function to determine if dark theme is enabled."
  (eq 1 (caar (dbus-ignore-errors
                (dbus-call-method
                 :session
                 "org.freedesktop.portal.Desktop"
                 "/org/freedesktop/portal/desktop"
                 "org.freedesktop.portal.Settings" "Read"
                 "org.freedesktop.appearance" "color-scheme")))))

(defun auto-dark--is-dark-mode-powershell ()
  "Invoke powershell using Emacs using external shell command."
  (string-equal "0" (string-trim (shell-command-to-string "powershell -noprofile -noninteractive \
-nologo -ex bypass -command Get-ItemPropertyValue \
HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize \
-Name AppsUseLightTheme"))))

(defun auto-dark--is-dark-mode-winreg ()
  "Use Emacs built-in Windows Registry function.
In order to determine if dark theme is enabled."
  (eq 0 (w32-read-registry 'HKCU
			   "Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize"
			   "AppsUseLightTheme")))

(defun auto-dark--is-dark-mode-termux ()
  "Use Termux way to determine if dark theme is enabled.  ref: https://github.com/termux/termux-api/issues/425."
  (string-equal "Night mode: yes"
                (shell-command-to-string "echo -n $(cmd uimode night 2>&1 </dev/null)")))

(defvar auto-dark-dark-mode-hook nil
  "List of hooks to run after dark mode is loaded." )

(defvar auto-dark-light-mode-hook nil
  "List of hooks to run after light mode is loaded." )

(defun auto-dark--is-dark-mode ()
  "If dark mode is enabled."
  (pcase auto-dark-detection-method
    ('applescript
     (auto-dark--is-dark-mode-applescript))
    ('osascript
     (auto-dark--is-dark-mode-osascript))
    ('dbus
     (auto-dark--is-dark-mode-dbus))
    ('powershell
     (auto-dark--is-dark-mode-powershell))
    ('winreg
     (auto-dark--is-dark-mode-winreg))
    ('termux
     (auto-dark--is-dark-mode-termux))))

(defun auto-dark--check-and-set-dark-mode ()
  "Set the theme according to the OS's dark mode state.
In order to prevent flickering, we only set the theme if we haven't
already set the theme for the current dark mode state."
  (let ((appearance (if (auto-dark--is-dark-mode) 'dark 'light)))
    (unless (eq appearance auto-dark--last-dark-mode-state)
      (auto-dark--set-theme appearance))))

(defun auto-dark--update-frame-backgrounds (appearance)
  "Set the `frame-background-mode' for all frames to APPEARANCE."
  (setq frame-background-mode appearance)
  (mapc #'frame-set-background-mode (frame-list)))

(defun auto-dark--enable-themes (&optional themes)
  "Re-enable THEMES, which defaults to ‘custom-enabled-themes’.
This will load themes if necessary."
  (interactive)
  (let ((full-themes (remq 'user
                           (delete-dups (or themes custom-enabled-themes)))))
    ;; Disable only the themes we’re not going to re-enable.
    (mapc (lambda (theme)
            (unless (memq theme full-themes)
              (disable-theme theme)))
          custom-enabled-themes)
    (let ((failures (mapcan (lambda (theme)
                              (condition-case nil
                                  ;; Enable instead of load when possible.
                                  (if (custom-theme-p theme)
                                      (enable-theme theme)
                                    (load-theme theme))
                                (:success nil)
                                (error (list theme))))
                            (reverse full-themes))))
      (when failures
        (warn "Failed to enable theme(s): %s"
              (mapconcat #'symbol-name failures ", "))))))

(defun auto-dark--set-theme (appearance)
  "Set light/dark theme Argument APPEARANCE should be light or dark."
  (setq auto-dark--last-dark-mode-state appearance)
  (auto-dark--update-frame-backgrounds appearance)
  (pcase appearance
    ('dark
     (auto-dark--enable-themes (auto-dark--dark-themes))
     (run-hooks 'auto-dark-dark-mode-hook))
    ('light
     (auto-dark--enable-themes (auto-dark--light-themes))
     (run-hooks 'auto-dark-light-mode-hook))))

(defvar auto-dark--timer nil)
(defun auto-dark-start-timer ()
  "Start auto-dark timer."
  (setq auto-dark--timer
        (run-with-timer 0 auto-dark-polling-interval-seconds #'auto-dark--check-and-set-dark-mode)))

(defun auto-dark-stop-timer ()
  "Stop auto-dark timer."
  (when (timerp auto-dark--timer)
    (cancel-timer auto-dark--timer)))

(defun auto-dark--register-dbus-listener ()
  "Register a callback function with D-Bus.
Ask D-Bus to send us a signal on theme change and add a callback
to change the theme."
  (setq auto-dark--dbus-listener-object
        (dbus-register-signal
         :session
         "org.freedesktop.portal.Desktop"
         "/org/freedesktop/portal/desktop"
         "org.freedesktop.portal.Settings"
         "SettingChanged"
         (lambda (path var val)
           (when (and (string= path "org.freedesktop.appearance")
                      (string= var "color-scheme"))
             (auto-dark--set-theme (pcase (car val) (0 'light) (1 'dark) (2 'light))))))))

(defun auto-dark--unregister-dbus-listener ()
  "Unregister our callback function with D-Bus.
Remove theme change callback registered with D-Bus."
  (dbus-unregister-object auto-dark--dbus-listener-object))

(defun auto-dark--register-change-listener ()
  "Register a listener to listen for the system theme to change."
  (cond
   ((auto-dark--use-ns-system-appearance)
    (add-hook 'ns-system-appearance-change-functions #'auto-dark--set-theme))
   ((auto-dark--use-mac-system-appearance)
    (add-hook 'mac-effective-appearance-change-hook #'auto-dark--check-and-set-dark-mode))
   ((auto-dark--use-dbus)
    (auto-dark--register-dbus-listener))
   (t (auto-dark-start-timer))))

(defun auto-dark--unregister-change-listener ()
  "Remove an existing listener for the system theme."
  (cond
   ((auto-dark--use-ns-system-appearance)
    (remove-hook 'ns-system-appearance-change-functions #'auto-dark--set-theme))
   ((auto-dark--use-mac-system-appearance)
    (remove-hook 'mac-effective-appearance-change-hook #'auto-dark--check-and-set-dark-mode))
   ((auto-dark--use-dbus)
    (auto-dark--unregister-dbus-listener))
   (t (auto-dark-stop-timer))))

(defun auto-dark--use-ns-system-appearance ()
  "Determine whether we should use the ns-system-appearance-* functions."
  (boundp 'ns-system-appearance-change-functions))

(defun auto-dark--use-mac-system-appearance ()
  "Determine whether we should use the `mac-effective-appearance-change-hook'."
  (boundp 'mac-effective-appearance-change-hook))

(defun auto-dark--use-dbus ()
  "Determine whether we should use the dbus-* functions."
  (eq auto-dark-detection-method 'dbus))

(defun auto-dark--determine-detection-method ()
  "Determine which theme detection method auto-dark should use."
  (cond
   ((and (eq system-type 'darwin)
         (or (fboundp 'ns-do-applescript)
             (fboundp 'mac-do-applescript))
		 (or (eq window-system 'ns)
			 (eq window-system 'mac)))
    'applescript)
   ((and (eq system-type 'darwin)
         auto-dark-allow-osascript)
    'osascript)
   ((and (eq system-type 'gnu/linux)
         (member 'dbus features)
         (member "org.freedesktop.portal.Desktop"
                 (dbus-list-activatable-names :session)))
    'dbus)
   ((and (eq system-type 'gnu/linux)
         (member 'dbus features)
         (cl-search "termux-fix-shebang"
                    (shell-command-to-string "command -v termux-fix-shebang")))
    'termux)
   ((and (eq system-type 'windows-nt)
         auto-dark-allow-powershell)
    'powershell)
   ((eq system-type 'windows-nt)
    'winreg)
   (t
    (error "Could not determine a viable theme detection mechanism!"))))

;;;###autoload
(define-minor-mode auto-dark-mode
  "Toggle `auto-dark-mode' on or off."
  :group 'auto-dark
  :global t
  :lighter " AD"
  (if auto-dark-mode
      (progn
        (unless auto-dark-detection-method
          (setq auto-dark-detection-method (auto-dark--determine-detection-method)))
        (auto-dark--check-and-set-dark-mode)
        (auto-dark--register-change-listener))
    (auto-dark--unregister-change-listener)))

(provide 'auto-dark)

;;; auto-dark.el ends here