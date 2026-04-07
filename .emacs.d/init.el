;;; init.el --- Master Loader for Org-Roam Research Hub -*- lexical-binding: t -*-
;;
;; This file loads all Research Hub Org-Roam modules in the correct order.
;;
;; Usage:
;;   Add this to your ~/.emacs.d/init.el or eval it directly:
;;
;;     (load "/path/to/Research_Hub_interanimated_papers/.emacs.d/init.el")
;;
;; Or, if you use this directory as your Emacs configuration:
;;     emacs --init-directory /path/to/Research_Hub_interanimated_papers/.emacs.d/
;;
;;; Commentary:
;;
;; Module load order:
;;   1. init-org-roam.el         — core Org-Roam (must be first)
;;   2. init-org-roam-ui.el      — visual rendering & graph UI
;;   3. init-org-roam-adhd.el    — ADHD helpers (timers, streaks, auto-save)
;;   4. init-org-roam-research.el— research workflows (literature, interanimated)
;;   5. init-org-roam-keybindings.el — unified keybinding map (must be last)
;;
;;; Code:

;;; ─────────────────────────────────────────────────────────────────────────────
;;; Bootstrap: ensure use-package is available
;;; ─────────────────────────────────────────────────────────────────────────────

;; Emacs 29+ ships use-package built-in.
(unless (fboundp 'use-package)
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/") t)
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
  (require 'use-package))

;; Always ensure packages are installed when declared with :ensure t.
(setq use-package-always-ensure t)

;;; ─────────────────────────────────────────────────────────────────────────────
;;; Module directory — set to this file's directory
;;; ─────────────────────────────────────────────────────────────────────────────

(defvar rh/config-dir
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing the Research Hub Org-Roam configuration modules.")

(defun rh/load-module (module)
  "Load MODULE (a symbol or string) from `rh/config-dir'.
Gracefully reports errors instead of crashing Emacs."
  (let ((file (expand-file-name (format "%s.el" module) rh/config-dir)))
    (if (file-exists-p file)
        (condition-case err
            (load file nil t)
          (error
           (message "⚠ Research Hub: failed to load %s — %s" module (error-message-string err))))
      (message "⚠ Research Hub: module not found: %s" file))))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; Load modules in order
;;; ─────────────────────────────────────────────────────────────────────────────

(rh/load-module "init-org-roam")           ; 1. Core (must be first)
(rh/load-module "init-org-roam-ui")        ; 2. Visual / UI
(rh/load-module "init-org-roam-adhd")      ; 3. ADHD helpers
(rh/load-module "init-org-roam-research")  ; 4. Research workflows
(rh/load-module "init-org-roam-keybindings") ; 5. Keybindings (last)

;;; ─────────────────────────────────────────────────────────────────────────────
;;; Package installation helper
;;; ─────────────────────────────────────────────────────────────────────────────

(defvar rh/required-packages
  '(org-roam
    org-roam-ui
    org-modern
    mixed-pitch
    olivetti
    writeroom-mode
    consult-org-roam
    consult
    vertico
    orderless
    marginalia
    org-pomodoro
    hydra)
  "All packages required by the Research Hub configuration.
Run `rh/install-packages' to install any that are missing.")

(defun rh/install-packages ()
  "Install all packages in `rh/required-packages' that are not yet installed.
Run this once after cloning the repository to bootstrap your environment."
  (interactive)
  (require 'package)
  (package-refresh-contents)
  (dolist (pkg rh/required-packages)
    (unless (package-installed-p pkg)
      (message "Installing %s..." pkg)
      (package-install pkg)))
  (message "✅ All Research Hub packages installed!"))

(provide 'init)
;;; init.el ends here
