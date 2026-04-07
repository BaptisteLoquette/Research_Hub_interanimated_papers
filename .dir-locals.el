;;; .dir-locals.el --- Project-specific Emacs settings for Research Hub
;;
;; These settings are automatically applied by Emacs when you visit any file
;; in this repository (see `dir-locals-file' in the Emacs manual).
;;
;; They configure Org-Roam to use THIS repository as the notes directory,
;; so you don't need to change your global Emacs config.

((nil
  . (;; ── Org-Roam directory ─────────────────────────────────────────────────
     ;; Point org-roam at the `org/' sub-directory of THIS project.
     (eval . (setq-local org-roam-directory
                         (expand-file-name "org/"
                                           (locate-dominating-file
                                            default-directory ".dir-locals.el"))))

     ;; ── Daily notes sub-directory ─────────────────────────────────────────
     (eval . (setq-local org-roam-dailies-directory "daily/"))

     ;; ── Exclude templates from the Org-Roam index ─────────────────────────
     (eval . (setq-local org-roam-file-exclude-regexp
                         (rx (or "templates/" ".git/" "archive/"))))

     ;; ── Load the Research Hub module loader ───────────────────────────────
     ;; Uncomment the line below if you want these settings to automatically
     ;; load the full Research Hub configuration when you open any file here.
     ;;
     ;; (eval . (load (expand-file-name ".emacs.d/init.el"
     ;;                                 (locate-dominating-file
     ;;                                  default-directory ".dir-locals.el"))
     ;;               nil t))
     ))

 ;; ── Org-mode specific settings ────────────────────────────────────────────
 (org-mode
  . ((fill-column . 80)
     (visual-line-mode . t)
     (org-startup-indented . t)
     (org-startup-folded . content)))))
