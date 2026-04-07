;;; init-org-roam-ui.el --- Visual / UI Configuration -*- lexical-binding: t -*-
;;
;; Part of the Research_Hub_interanimated_papers Org-Roam setup.
;; Optimized for ADHD, visual/outliner-first note-taking.
;;
;;; Commentary:
;;
;; This module configures:
;;   - org-modern: clean, icon-rich rendering with ADHD-friendly heading hierarchy
;;   - org-roam-ui: interactive knowledge-graph browser with theme sync
;;   - mixed-pitch-mode: proportional fonts for prose, monospace for code
;;   - olivetti-mode / writeroom-mode: distraction-free writing
;;   - Custom heading-level faces (rainbow-like distinct colors)
;;   - Visual line mode and word wrap
;;   - Inline image auto-display
;;   - org-superstar fallback if org-modern is unavailable
;;
;;; Code:

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 1. org-modern — Beautiful, modern Org rendering
;;; ─────────────────────────────────────────────────────────────────────────────

(use-package org-modern
  :ensure t
  :hook
  ((org-mode           . org-modern-mode)
   (org-agenda-finalize . org-modern-agenda))
  :custom
  ;; ── Heading stars (ADHD: distinct shapes per level) ───────────────────────
  (org-modern-star '("◉" "○" "◈" "◇" "▸" "▹"))

  ;; ── Tables ────────────────────────────────────────────────────────────────
  (org-modern-table-vertical 1)
  (org-modern-table-horizontal 0.2)

  ;; ── Source/example block delimiters ───────────────────────────────────────
  (org-modern-block-name
   '(("src"     . ("⌜" "⌟"))
     ("example" . ("⟦" "⟧"))
     ("quote"   . ("❝" "❞"))
     ("export"  . ("⎡" "⎦"))))

  ;; ── Keywords & priorities ─────────────────────────────────────────────────
  (org-modern-keyword nil)     ; keep #+KEYWORD as-is (less visual noise)
  (org-modern-todo t)
  (org-modern-priority t)
  (org-modern-tag t)

  ;; ── Checkbox style ────────────────────────────────────────────────────────
  (org-modern-checkbox
   '((?X . "☑") (?- . "◐") (?\s . "☐")))

  ;; ── Timestamps ────────────────────────────────────────────────────────────
  (org-modern-timestamp t)

  ;; ── Statistics cookies (e.g. [2/5]) ──────────────────────────────────────
  (org-modern-statistics t)

  :config
  ;; Disable block fringe to avoid visual conflicts with margins.
  (setq org-modern-block-fringe nil))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 2. Fallback: org-superstar (if org-modern is not available)
;;; ─────────────────────────────────────────────────────────────────────────────

;; Only activate if org-modern failed to load.
(unless (featurep 'org-modern)
  (use-package org-superstar
    :ensure t
    :hook (org-mode . org-superstar-mode)
    :custom
    (org-superstar-headline-bullets-list '("◉" "○" "◈" "◇" "▸"))
    (org-superstar-special-todo-items t)))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 3. Custom heading faces — distinct rainbow-like colors per level
;;; ─────────────────────────────────────────────────────────────────────────────

(defun rh/setup-org-heading-faces ()
  "Apply distinct, ADHD-friendly colors to each Org heading level.
Uses accessible, high-contrast colors that work on both light and dark themes."
  (face-remap-add-relative 'org-level-1 :foreground "#E06C75" :weight 'bold   :height 1.25)
  (face-remap-add-relative 'org-level-2 :foreground "#E5C07B" :weight 'bold   :height 1.15)
  (face-remap-add-relative 'org-level-3 :foreground "#98C379" :weight 'semi-bold :height 1.10)
  (face-remap-add-relative 'org-level-4 :foreground "#56B6C2" :weight 'normal :height 1.05)
  (face-remap-add-relative 'org-level-5 :foreground "#C678DD" :weight 'normal :height 1.0)
  (face-remap-add-relative 'org-level-6 :foreground "#61AFEF" :weight 'normal :height 1.0)
  (face-remap-add-relative 'org-level-7 :foreground "#ABB2BF" :weight 'normal :height 1.0)
  (face-remap-add-relative 'org-level-8 :foreground "#5C6370" :weight 'normal :height 1.0))

(add-hook 'org-mode-hook #'rh/setup-org-heading-faces)

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 4. mixed-pitch-mode — Proportional fonts for prose, monospace for code
;;; ─────────────────────────────────────────────────────────────────────────────

(use-package mixed-pitch
  :ensure t
  :hook (org-mode . mixed-pitch-mode)
  :config
  ;; Ensure tables and src blocks stay monospace.
  (push 'org-table mixed-pitch-fixed-pitch-faces)
  (push 'org-code  mixed-pitch-fixed-pitch-faces)
  (push 'org-block mixed-pitch-fixed-pitch-faces))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 5. olivetti-mode — Distraction-free, centred writing
;;; ─────────────────────────────────────────────────────────────────────────────

(use-package olivetti
  :ensure t
  :hook (org-mode . olivetti-mode)
  :custom
  ;; 80-character body width gives comfortable reading line length.
  (olivetti-body-width 82))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 6. writeroom-mode — Full-screen distraction-free mode (on-demand)
;;; ─────────────────────────────────────────────────────────────────────────────

(use-package writeroom-mode
  :ensure t
  :commands writeroom-mode
  :custom
  (writeroom-width 90)
  (writeroom-mode-line nil)           ; Hide modeline in writeroom
  (writeroom-global-effects
   '(writeroom-set-alpha
     writeroom-set-menu-bar-lines
     writeroom-set-tool-bar-lines
     writeroom-set-vertical-scroll-bars
     writeroom-set-bottom-divider-width))
  :config
  ;; Bind toggle in org-mode — keybindings module also sets C-c n z.
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "C-c z") #'writeroom-mode)))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 7. org-roam-ui — Interactive knowledge graph in browser
;;; ─────────────────────────────────────────────────────────────────────────────

(use-package org-roam-ui
  :ensure t
  :after org-roam
  :commands (org-roam-ui-mode org-roam-ui-open)
  :custom
  ;; Match the current Emacs colour theme in the browser.
  (org-roam-ui-sync-theme t)
  ;; Highlight the node for the file currently open in Emacs.
  (org-roam-ui-follow t)
  ;; Re-render graph whenever you save a roam file.
  (org-roam-ui-update-on-save t)
  ;; Don't launch the browser on Emacs startup.
  (org-roam-ui-open-on-start nil))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 8. Visual-line & word-wrap defaults for Org
;;; ─────────────────────────────────────────────────────────────────────────────

(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook (lambda () (setq word-wrap t)))

;; Disable line numbers in Org buffers — they break the "writing" feel.
(add-hook 'org-mode-hook (lambda ()
                           (when (fboundp 'display-line-numbers-mode)
                             (display-line-numbers-mode -1))))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 9. Inline image auto-display
;;; ─────────────────────────────────────────────────────────────────────────────

(defun rh/org-display-inline-images-maybe ()
  "Display inline images in Org buffer if they are present.
Called after visiting a file and after inserting a link."
  (when (org-roam-file-p)
    (org-display-inline-images)))

(add-hook 'org-mode-hook #'rh/org-display-inline-images-maybe)

;; Refresh images after saving (in case an image path was just added).
(add-hook 'after-save-hook
          (lambda ()
            (when (and (eq major-mode 'org-mode)
                       (org-roam-file-p))
              (org-display-inline-images))))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 10. Outline navigation helpers
;;; ─────────────────────────────────────────────────────────────────────────────

(defun rh/org-outline-search ()
  "Jump to a heading in the current Org buffer using consult.
Falls back to `imenu' if consult is not available."
  (interactive)
  (if (fboundp 'consult-outline)
      (consult-outline)
    (imenu nil)))

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c o") #'rh/org-outline-search))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 11. Backlinks buffer configuration
;;; ─────────────────────────────────────────────────────────────────────────────

(setq org-roam-buffer-position 'right)
(setq org-roam-buffer-width 0.30)

(provide 'init-org-roam-ui)
;;; init-org-roam-ui.el ends here
