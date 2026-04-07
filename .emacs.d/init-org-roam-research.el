;;; init-org-roam-research.el --- Research-Specific Workflows -*- lexical-binding: t -*-
;;
;; Part of the Research_Hub_interanimated_papers Org-Roam setup.
;;
;;; Commentary:
;;
;; This module provides research-specific tooling:
;;
;;   - Literature note capture helpers with structured fields
;;   - Interanimated-papers workflow (tracking paper dialogues)
;;   - Research question tracker
;;   - Reading list management
;;   - Export helpers (Markdown, PDF)
;;   - Annotation workflow bridge (for PDF highlights → Org)
;;
;;; Code:

(require 'org-roam)

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 1. Literature note capture with interactive prompts
;;; ─────────────────────────────────────────────────────────────────────────────

(defun rh/new-literature-note (title author year doi venue)
  "Create a new literature note with pre-filled metadata fields.
TITLE is the paper/book title.
AUTHOR is the author(s) string.
YEAR is the publication year (string).
DOI is the DOI or URL.
VENUE is the journal/conference/publisher name."
  (interactive
   (list (read-string "Title: ")
         (read-string "Author(s): ")
         (read-string "Year: ")
         (read-string "DOI / URL: ")
         (read-string "Journal / Venue: ")))
  (let* ((slug (org-roam-node-slug (org-roam-node-create :title title)))
         (file (expand-file-name
                (concat "literature/" slug ".org")
                org-roam-directory))
         (header (format "#+title: %s
#+created: %s
#+filetags: :literature:research:
#+ROAM_REFS: %s

* Metadata
- Author(s): %s
- Year: %s
- DOI/URL: %s
- Journal/Venue: %s

* Abstract/Summary

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
                         title
                         (format-time-string "[%Y-%m-%d %a %H:%M]")
                         doi author year doi venue)))
    (unless (file-exists-p file)
      (with-temp-file file
        (insert header)))
    (find-file file)
    (org-roam-db-update-file file)
    (message "📚 Literature note created: %s" title)))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 2. Interanimated papers workflow
;;; ─────────────────────────────────────────────────────────────────────────────

(defun rh/new-interanimated-note (title paper-a paper-b interaction-type)
  "Create an interanimated-papers note linking PAPER-A and PAPER-B.
TITLE describes the dialogue.
INTERACTION-TYPE is one of: builds-upon, contradicts, extends, synthesizes, critiques."
  (interactive
   (list (read-string "Note title (describe the dialogue): ")
         (read-string "Paper A (title or [[link]]): ")
         (read-string "Paper B (title or [[link]]): ")
         (completing-read "Interaction type: "
                          '("builds-upon" "contradicts" "extends"
                            "synthesizes" "critiques")
                          nil t)))
  (let* ((slug (org-roam-node-slug (org-roam-node-create :title title)))
         (file (expand-file-name
                (concat "interanimated/" slug ".org")
                org-roam-directory))
         ;; Build the checkbox list with the selected interaction checked.
         (checkbox-list
          (mapcar (lambda (type)
                    (if (string= type interaction-type)
                        (format "- [X] %s" type)
                      (format "- [ ] %s" type)))
                  '("builds-upon" "contradicts" "extends" "synthesizes" "critiques")))
         (content (format "#+title: %s
#+created: %s
#+filetags: :interanimated:dialogue:

* Papers in Dialogue
- Paper A: %s
- Paper B: %s

* Nature of Interaction
%s

* Key Points of Contact

* Emergent Insights

* Implications for My Research
"
                          title
                          (format-time-string "[%Y-%m-%d %a %H:%M]")
                          paper-a paper-b
                          (mapconcat #'identity checkbox-list "\n"))))
    (unless (file-exists-p file)
      (with-temp-file file
        (insert content)))
    (find-file file)
    (org-roam-db-update-file file)
    (message "🔗 Interanimated note created: %s" title)))

(defun rh/list-interanimated-notes ()
  "List all interanimated-papers notes in a completing-read and jump to one."
  (interactive)
  (let* ((interanimated-dir (expand-file-name "interanimated/" org-roam-directory))
         (files (when (file-directory-p interanimated-dir)
                  (directory-files interanimated-dir t "\\.org$"))))
    (if (null files)
        (message "No interanimated notes yet. Create one with rh/new-interanimated-note.")
      (find-file
       (completing-read "Interanimated note: "
                        (mapcar #'file-name-nondirectory files)
                        nil t nil nil nil
                        (lambda (name)
                          (expand-file-name name interanimated-dir)))))))

(defun rh/interanimation-map ()
  "Open the org-roam-ui graph filtered to interanimated notes.
Requires org-roam-ui to be running."
  (interactive)
  (if (fboundp 'org-roam-ui-mode)
      (progn
        (org-roam-ui-mode 1)
        (message "🕸 Graph open — filter by tag :interanimated: in the browser UI"))
    (message "org-roam-ui not available. Install it for the interactive graph.")))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 3. Research question tracker
;;; ─────────────────────────────────────────────────────────────────────────────

(defvar rh/research-questions-file
  (expand-file-name "research-questions.org" (bound-and-true-p org-roam-directory))
  "Path to the dedicated research questions file.")

(defun rh/research-questions ()
  "Open the research questions tracker file.
Creates it with a template if it doesn't exist."
  (interactive)
  (let ((file rh/research-questions-file))
    (unless (file-exists-p file)
      (with-temp-file file
        (insert "#+title: Research Questions
#+created: " (format-time-string "[%Y-%m-%d %a %H:%M]") "
#+filetags: :research:questions:

* Open Questions
** TODO

* Questions Under Investigation
** IN-PROGRESS

* Answered Questions
** DONE

* Discarded Questions
** CANCELLED
")))
    (find-file file)
    (org-roam-db-update-file file)))

(defun rh/add-research-question (question)
  "Add a new research QUESTION as a TODO heading in the research questions file."
  (interactive "sNew research question: ")
  (rh/research-questions)
  (goto-char (point-min))
  (search-forward "* Open Questions")
  (forward-line 1)
  (insert (format "** TODO %s\n   :PROPERTIES:\n   :CREATED: %s\n   :END:\n\n"
                  question
                  (format-time-string "[%Y-%m-%d %a %H:%M]")))
  (save-buffer)
  (message "❓ Research question added: %s" question))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 4. Reading list management
;;; ─────────────────────────────────────────────────────────────────────────────

(defvar rh/reading-list-file
  (expand-file-name "reading-list.org" (bound-and-true-p org-roam-directory))
  "Path to the reading list file.")

(defun rh/reading-list ()
  "Open the reading list.  Creates it with a template if it doesn't exist."
  (interactive)
  (let ((file rh/reading-list-file))
    (unless (file-exists-p file)
      (with-temp-file file
        (insert "#+title: Reading List
#+created: " (format-time-string "[%Y-%m-%d %a %H:%M]") "
#+filetags: :reading:list:

* To Read
** TODO

* Currently Reading
** IN-PROGRESS

* Read — To Process
** TODO [needs literature note]

* Done
** DONE
")))
    (find-file file)
    (org-roam-db-update-file file)))

(defun rh/add-to-reading-list (title author doi)
  "Add a paper/book to the reading list.
TITLE, AUTHOR, DOI are the paper's metadata."
  (interactive
   (list (read-string "Title: ")
         (read-string "Author(s): ")
         (read-string "DOI / URL: ")))
  (rh/reading-list)
  (goto-char (point-min))
  (search-forward "* To Read")
  (forward-line 1)
  (insert (format "** TODO %s\n   :PROPERTIES:\n   :AUTHOR: %s\n   :DOI: %s\n   :ADDED: %s\n   :END:\n\n"
                  title author doi
                  (format-time-string "[%Y-%m-%d %a %H:%M]")))
  (save-buffer)
  (message "📖 Added to reading list: %s" title))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 5. Export helpers
;;; ─────────────────────────────────────────────────────────────────────────────

(defun rh/export-to-markdown ()
  "Export the current Org-Roam note to GitHub-Flavored Markdown.
The .md file is saved in the same directory as the .org file."
  (interactive)
  (unless (eq major-mode 'org-mode)
    (user-error "Not in an Org buffer"))
  (require 'ox-md)
  (let ((org-export-with-toc t)
        (org-export-with-section-numbers nil))
    (org-md-export-to-markdown)
    (message "✅ Exported to Markdown: %s"
             (file-name-nondirectory
              (concat (file-name-sans-extension buffer-file-name) ".md")))))

(defun rh/export-to-pdf ()
  "Export the current Org-Roam note to PDF via LaTeX.
Requires a working LaTeX installation (e.g., TeX Live)."
  (interactive)
  (unless (eq major-mode 'org-mode)
    (user-error "Not in an Org buffer"))
  (require 'ox-latex)
  (org-latex-export-to-pdf)
  (message "✅ Exported to PDF: %s"
           (file-name-nondirectory
            (concat (file-name-sans-extension buffer-file-name) ".pdf"))))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 6. PDF annotation workflow (requires pdf-tools)
;;; ─────────────────────────────────────────────────────────────────────────────

;; org-noter provides integrated PDF ↔ Org annotation.
;; Uncomment to enable.
;;
;; (use-package org-noter
;;   :ensure t
;;   :after org
;;   :commands (org-noter org-noter-insert-note)
;;   :custom
;;   (org-noter-notes-search-path (list org-roam-directory))
;;   (org-noter-separate-notes-from-heading t)
;;   (org-noter-always-create-frame nil)
;;   (org-noter-kill-frame-at-session-end nil))

;; pdf-tools for in-Emacs PDF viewing.
;;
;; (use-package pdf-tools
;;   :ensure t
;;   :config
;;   (pdf-tools-install)
;;   (setq-default pdf-view-display-size 'fit-width))

(defun rh/import-pdf-annotations (pdf-file note-file)
  "Stub: import highlights from PDF-FILE into NOTE-FILE as Org headings.
Requires pdf-tools and org-noter to be installed and enabled.
See the commented-out blocks above to activate this workflow."
  (interactive
   (list (read-file-name "PDF file: " nil nil t nil
                         (lambda (f) (string-suffix-p ".pdf" f)))
         (read-file-name "Target Org note: " org-roam-directory nil nil
                         nil (lambda (f) (string-suffix-p ".org" f)))))
  (message
   "📎 To import PDF annotations:\n1. Enable org-noter (see init-org-roam-research.el)\n2. Open %s\n3. Run M-x org-noter"
   pdf-file))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 7. Tag-based note navigation helpers
;;; ─────────────────────────────────────────────────────────────────────────────

(defun rh/find-notes-by-tag (tag)
  "List all Org-Roam notes that have TAG and open the selected one."
  (interactive "sTag to search: ")
  (let* ((nodes (org-roam-db-query
                 [:select [nodes:title nodes:file]
                  :from nodes
                  :inner-join tags :on (= nodes:id tags:node-id)
                  :where (= tags:tag $s1)]
                 tag))
         (candidates
          (mapcar (lambda (row) (cons (car row) (cadr row))) nodes)))
    (if (null candidates)
        (message "No notes found with tag: %s" tag)
      (find-file
       (cdr (assoc
             (completing-read (format "Notes tagged :%s: (%d): " tag (length candidates))
                              candidates nil t)
             candidates))))))

(provide 'init-org-roam-research)
;;; init-org-roam-research.el ends here
