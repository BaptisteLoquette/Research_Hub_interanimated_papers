;;; init-org-roam.el --- Core Org-Roam Configuration -*- lexical-binding: t -*-
;;
;; Part of the Research_Hub_interanimated_papers Org-Roam setup.
;; Optimized for ADHD, visual/outliner-first note-taking, and technical research.
;;
;; Load order: This file should be loaded first (core), then ui, adhd, research, keybindings.
;; Master loader: init.el loads all modules in the correct order.
;;
;;; Commentary:
;;
;; This module configures:
;;   - org-roam core with project-relative directory
;;   - org-roam-db-autosync-mode
;;   - Capture templates: default, fleeting, literature, research-project,
;;     concept, methodology, interanimated
;;   - Dailies configuration for research journaling
;;   - Node display template (tags + file info in minibuffer)
;;   - Performance tuning (GC threshold, file exclusions, lazy loading)
;;   - consult-org-roam fuzzy search integration
;;   - org-cite for citation management
;;
;;; Code:

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 0. Performance: raise GC threshold during startup
;;; ─────────────────────────────────────────────────────────────────────────────

;; Defer garbage collection during heavy operations (restored by gcmh or manually).
(setq gc-cons-threshold (* 128 1024 1024))   ; 128 MB during load
(setq gc-cons-percentage 0.6)

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 1. Directory setup
;;; ─────────────────────────────────────────────────────────────────────────────

(defvar rh/org-roam-directory
  (or (bound-and-true-p org-roam-directory)
      (expand-file-name "org/" (file-name-directory
                                (or load-file-name buffer-file-name default-directory))))
  "Root directory for all Org-Roam notes in this project.
Falls back to the `org/' sub-directory of the repository root.")

;; Ensure all sub-directories exist at load time.
(defvar rh/org-roam-subdirs
  '("daily" "literature" "fleeting" "projects" "concepts"
    "methodology" "interanimated" "templates")
  "List of sub-directories to create inside `rh/org-roam-directory'.")

(defun rh/ensure-org-dirs ()
  "Create all required Org-Roam sub-directories if they do not exist."
  (dolist (dir rh/org-roam-subdirs)
    (let ((path (expand-file-name dir rh/org-roam-directory)))
      (unless (file-directory-p path)
        (make-directory path t)))))

(rh/ensure-org-dirs)

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 2. Core org-roam package
;;; ─────────────────────────────────────────────────────────────────────────────

(use-package org-roam
  :ensure t
  :demand t  ; Load immediately — required by other modules.

  :init
  ;; Acknowledge v2 migration (suppresses the one-time warning).
  (setq org-roam-v2-ack t)

  :custom
  ;; ── Directories ────────────────────────────────────────────────────────────
  (org-roam-directory rh/org-roam-directory)
  (org-roam-dailies-directory "daily/")

  ;; ── Performance ────────────────────────────────────────────────────────────
  ;; Avoid GC pauses while org-roam rebuilds/queries the database.
  (org-roam-db-gc-threshold most-positive-fixnum)

  ;; Exclude directories that should not be indexed.
  (org-roam-file-exclude-regexp
   (rx (or ".stversions/" "logseq/" "archive/" ".git/" "templates/")))

  ;; ── Completion ─────────────────────────────────────────────────────────────
  ;; Allow [[node completion]] anywhere in any org buffer.
  (org-roam-completion-everywhere t)

  ;; ── Node display in minibuffer ─────────────────────────────────────────────
  ;; Shows:  Title (padded)   :tags:   filename
  (org-roam-node-display-template
   (concat "${title:55} "
           (propertize "${tags:35}" 'face 'org-tag)
           " "
           (propertize "${file:30}" 'face 'font-lock-comment-face)))

  ;; ── Capture templates ──────────────────────────────────────────────────────
  (org-roam-capture-templates
   '(;;────────────────────────────────────────────────────────────────────────
     ;; "d" — Default / permanent note (press RET to confirm)
     ;;────────────────────────────────────────────────────────────────────────
     ("d" "📝 Default note" plain
      "%?"
      :if-new (file+head "${slug}.org"
                         "#+title: ${title}
#+created: %U
#+filetags:

")
      :unnarrowed t)

     ;;────────────────────────────────────────────────────────────────────────
     ;; "f" — Fleeting (quick capture, ADHD-friendly)
     ;;────────────────────────────────────────────────────────────────────────
     ("f" "⚡ Fleeting thought" plain
      "%?"
      :if-new (file+head "fleeting/${slug}.org"
                         "#+title: ${title}
#+created: %U
#+filetags: :fleeting:

")
      :unnarrowed t
      :immediate-finish nil)

     ;;────────────────────────────────────────────────────────────────────────
     ;; "l" — Literature note (academic paper / book)
     ;;────────────────────────────────────────────────────────────────────────
     ("l" "📚 Literature note" plain
      "* Metadata
- Author(s): %^{Author(s)}
- Year: %^{Year}
- DOI/URL: %^{DOI or URL}
- Journal/Venue: %^{Journal or Venue}

* Abstract/Summary

%?

* Key Ideas
-

* Methodology

* Findings

* Connections
- Related to:
- Builds on:
- Contradicts:

* My Thoughts

* Quotes
"
      :if-new (file+head "literature/${slug}.org"
                         "#+title: ${title}
#+created: %U
#+filetags: :literature:research:
#+ROAM_REFS: ${ref}

")
      :unnarrowed t)

     ;;────────────────────────────────────────────────────────────────────────
     ;; "r" — Research project
     ;;────────────────────────────────────────────────────────────────────────
     ("r" "🔬 Research project" plain
      "* Overview
%?

* Research Question(s)
-

* Hypotheses
-

* Methodology
** Approach
** Data Sources
** Tools

* Findings
** Key Results
** Null Results

* Related Work
-

* Open Questions
-

* Next Steps
** TODO
"
      :if-new (file+head "projects/${slug}.org"
                         "#+title: ${title}
#+created: %U
#+filetags: :research:project:

")
      :unnarrowed t)

     ;;────────────────────────────────────────────────────────────────────────
     ;; "c" — Concept / evergreen idea
     ;;────────────────────────────────────────────────────────────────────────
     ("c" "💡 Concept / Idea" plain
      "* Definition
%?

* Why It Matters

* Examples
-

* Connections
-

* Sources
-
"
      :if-new (file+head "concepts/${slug}.org"
                         "#+title: ${title}
#+created: %U
#+filetags: :concept:

")
      :unnarrowed t)

     ;;────────────────────────────────────────────────────────────────────────
     ;; "m" — Methodology note
     ;;────────────────────────────────────────────────────────────────────────
     ("m" "⚙️  Methodology" plain
      "* Description
%?

* When to Use

* Steps / Protocol
1.

* Strengths
-

* Limitations
-

* Examples in Literature
-

* My Experience
"
      :if-new (file+head "methodology/${slug}.org"
                         "#+title: ${title}
#+created: %U
#+filetags: :methodology:

")
      :unnarrowed t)

     ;;────────────────────────────────────────────────────────────────────────
     ;; "i" — Interanimated papers (dialogue between papers)
     ;;────────────────────────────────────────────────────────────────────────
     ("i" "🔗 Interanimated papers" plain
      "* Papers in Dialogue
- Paper A:
- Paper B:

* Nature of Interaction
- [ ] Builds upon
- [ ] Contradicts
- [ ] Extends
- [ ] Synthesizes
- [ ] Critiques

* Key Points of Contact
%?

* Emergent Insights

* Implications for My Research
"
      :if-new (file+head "interanimated/${slug}.org"
                         "#+title: ${title}
#+created: %U
#+filetags: :interanimated:dialogue:

")
      :unnarrowed t)))

  ;; ── Dailies templates ──────────────────────────────────────────────────────
  (org-roam-dailies-capture-templates
   '(;;────────────────────────────────────────────────────────────────────────
     ;; "d" — Default daily entry (timestamped)
     ;;────────────────────────────────────────────────────────────────────────
     ("d" "📅 Journal entry" entry
      "* %<%H:%M> %?"
      :if-new (file+head "%<%Y-%m-%d>.org"
                         "#+title: %<%Y-%m-%d (%A)>
#+filetags: :daily:

"))

     ;;────────────────────────────────────────────────────────────────────────
     ;; "t" — Task / TODO for the day
     ;;────────────────────────────────────────────────────────────────────────
     ("t" "✅ Task" entry
      "* TODO %?\nSCHEDULED: %t\n"
      :if-new (file+head "%<%Y-%m-%d>.org"
                         "#+title: %<%Y-%m-%d (%A)>
#+filetags: :daily:

"))

     ;;────────────────────────────────────────────────────────────────────────
     ;; "r" — Research log entry
     ;;────────────────────────────────────────────────────────────────────────
     ("r" "🔬 Research log" entry
      "* %<%H:%M> Research: %?\n"
      :if-new (file+head "%<%Y-%m-%d>.org"
                         "#+title: %<%Y-%m-%d (%A)>
#+filetags: :daily:

"))))

  :bind
  ;; Defined here for discoverability; the full hydra is in init-org-roam-keybindings.el.
  (("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n l" . org-roam-buffer-toggle)
   ("C-c n c" . org-roam-capture)
   ("C-c n g" . org-roam-graph)
   ("C-c n d" . org-roam-dailies-goto-today)
   ("C-c n D" . org-roam-dailies-capture-today)
   ("C-c n j" . org-roam-dailies-goto-date)
   ("C-c n a" . org-roam-alias-add)
   ("C-c n t" . org-roam-tag-add))

  :config
  ;; Start the database auto-sync daemon.
  (org-roam-db-autosync-mode))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 3. consult-org-roam — Fuzzy full-text search
;;; ─────────────────────────────────────────────────────────────────────────────

(use-package consult-org-roam
  :ensure t
  :after (consult org-roam)
  :init
  (consult-org-roam-mode 1)
  :custom
  ;; Use ripgrep for full-text search (must have `rg` installed).
  (consult-org-roam-grep-func #'consult-ripgrep)
  :bind
  (("C-c n s" . consult-org-roam-search)
   ("C-c n b" . consult-org-roam-backlinks)
   ("C-c n B" . consult-org-roam-forward-links)))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 4. org-cite — Citation management
;;; ─────────────────────────────────────────────────────────────────────────────

;; org-cite ships with Org 9.5+; no extra package needed.
(with-eval-after-load 'oc
  ;; Use citar as the citation UI if available; fall back to basic.
  (if (fboundp 'citar-open)
      (progn
        (require 'oc-citar nil t)
        (setq org-cite-insert-processor 'citar
              org-cite-follow-processor 'citar
              org-cite-activate-processor 'citar))
    (setq org-cite-insert-processor 'basic
          org-cite-follow-processor 'basic
          org-cite-activate-processor 'basic)))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 5. org-roam-bibtex — BibTeX/Zotero integration (disabled by default)
;;; ─────────────────────────────────────────────────────────────────────────────

;; Uncomment the block below to enable BibTeX/Zotero integration.
;; Requires: `org-roam-bibtex' and `bibtex-completion' packages.
;;
;; (use-package org-roam-bibtex
;;   :ensure t
;;   :after org-roam
;;   :hook (org-roam-mode . org-roam-bibtex-mode)
;;   :custom
;;   ;; Point this at your .bib file or Zotero Better BibTeX export.
;;   (orb-preformat-keywords '("citekey" "title" "url" "author-or-editor" "keywords" "file"))
;;   (orb-process-file-keyword t)
;;   (orb-file-field-extensions '("pdf")))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 6. Quality-of-life Org settings
;;; ─────────────────────────────────────────────────────────────────────────────

(with-eval-after-load 'org
  ;; Navigation
  (setq org-return-follows-link t)            ; RET opens links
  (setq org-id-link-to-org-use-id 'use-existing) ; Prefer stable ID links

  ;; Visual
  (setq org-hide-emphasis-markers t)          ; Hide /italic/ *bold* markers
  (setq org-pretty-entities t)                ; Render \alpha → α
  (setq org-startup-indented t)               ; Clean indented view
  (setq org-startup-folded 'content)          ; Show headings, hide bodies
  (setq org-startup-with-inline-images t)     ; Show images on open
  (setq org-image-actual-width '(500))        ; Cap inline image width
  (setq org-ellipsis " ▾")                    ; Prettier fold indicator

  ;; Tasks & logging
  (setq org-log-done 'time)                   ; Timestamp completed tasks
  (setq org-log-into-drawer t)                ; Keep log tidy in LOGBOOK
  (setq org-todo-keywords
        '((sequence "TODO(t)" "IN-PROGRESS(i!)" "WAITING(w@)" "|"
                    "DONE(d!)" "CANCELLED(c@)")))

  ;; Source blocks
  (setq org-src-fontify-natively t)           ; Syntax-highlight src blocks
  (setq org-src-tab-acts-natively t)          ; TAB works in src blocks
  (setq org-src-preserve-indentation t)       ; Don't mangle indentation
  (setq org-confirm-babel-evaluate nil))      ; Don't prompt on C-c C-c

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 7. Restore GC after startup
;;; ─────────────────────────────────────────────────────────────────────────────

;; Lower GC threshold back to a reasonable value after init.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)  ; 16 MB at runtime
                  gc-cons-percentage 0.1)))

(provide 'init-org-roam)
;;; init-org-roam.el ends here
