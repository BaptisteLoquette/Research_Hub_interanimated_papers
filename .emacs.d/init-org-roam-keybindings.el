;;; init-org-roam-keybindings.el --- Unified Keybinding Map -*- lexical-binding: t -*-
;;
;; Part of the Research_Hub_interanimated_papers Org-Roam setup.
;;
;;; Commentary:
;;
;; All keybindings live under the C-c n prefix.
;; A transient/hydra menu provides discoverability for new users.
;;
;; Groups:
;;   C-c n [capture]   n f q l r c m i d D
;;   C-c n [navigate]  f i l b B g
;;   C-c n [search]    s / o ?
;;   C-c n [focus]     p P F z
;;   C-c n [review]    w W k K
;;   C-c n [research]  R L I Q
;;
;; Requires: transient (ships with Emacs 28+) or hydra (optional fallback).
;;
;;; Code:

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 1. Transient prefix — C-c n (main Org-Roam menu)
;;; ─────────────────────────────────────────────────────────────────────────────

(with-eval-after-load 'transient

  (transient-define-prefix rh/org-roam-menu ()
    "Org-Roam command menu — Research Hub."
    :info-manual "(org-roam)"

    ["📝 Capture"
     ("n" "New note (default)"      org-roam-node-find)
     ("f" "Fleeting thought"        rh/capture-fleeting)
     ("l" "Literature note"         rh/capture-literature)
     ("r" "Research project"        rh/capture-research)
     ("c" "Concept / idea"          rh/capture-concept)
     ("m" "Methodology"             rh/capture-methodology)
     ("i" "Interanimated papers"    rh/capture-interanimated)
     ("d" "Daily journal (today)"   org-roam-dailies-goto-today)
     ("D" "Capture into today"      org-roam-dailies-capture-today)
     ("j" "Jump to a date"          org-roam-dailies-goto-date)]

    ["🔍 Navigate & Search"
     ("SPC" "Find / create note"    org-roam-node-find)
     ("I"   "Insert link"           org-roam-node-insert)
     ("L"   "Toggle backlinks"      org-roam-buffer-toggle)
     ("s"   "Full-text search"      consult-org-roam-search)
     ("b"   "Backlinks search"      consult-org-roam-backlinks)
     ("B"   "Forward links search"  consult-org-roam-forward-links)
     ("g"   "Knowledge graph"       org-roam-ui-mode)
     ("G"   "Open graph in browser" org-roam-ui-open)]

    ["🔬 Research Tools"
     ("R"   "Reading list"          rh/reading-list)
     ("Q"   "Research questions"    rh/research-questions)
     ("X"   "Interanimation map"    rh/interanimation-map)
     ("E"   "Export to markdown"    rh/export-to-markdown)
     ("P"   "Export to PDF"         rh/export-to-pdf)]

    ["🧠 ADHD & Focus"
     ("p"   "Start Pomodoro"        org-pomodoro)
     ("T"   "Custom focus timer"    rh/start-focus-timer)
     ("x"   "Cancel focus timer"    rh/cancel-focus-timer)
     ("F"   "Focus mode (toggle)"   rh/focus-mode)
     ("z"   "Writeroom mode"        writeroom-mode)
     ("w"   "Where was I?"          rh/where-was-i)
     ("u"   "Brain dump"            rh/brain-dump)
     ("k"   "Show streak"           rh/show-streak)]

    ["📊 Review & Stats"
     ("o"   "Find orphan notes"     rh/org-roam-find-orphans)
     ("?"   "Stats (note/link/tag)" rh/org-roam-stats)
     ("a"   "Add alias"             org-roam-alias-add)
     ("t"   "Add tag"               org-roam-tag-add)
     ("C"   "Capture (menu)"        org-roam-capture)])

  ;; Bind the menu to C-c n (overrides individual C-c n * bindings when menu is desired).
  (global-set-key (kbd "C-c n") #'rh/org-roam-menu))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 2. Hydra fallback (if transient is unavailable — Emacs < 28)
;;; ─────────────────────────────────────────────────────────────────────────────

(unless (featurep 'transient)
  (use-package hydra
    :ensure t
    :config
    (defhydra rh/hydra-org-roam (:color blue :hint nil)
      "
╔══════════════════════════════════════════════════════════════╗
║                 Org-Roam — Research Hub                       ║
╠══════════════╦═══════════════════╦══════════════════════════╣
║  📝 CAPTURE  ║  🔍 NAVIGATE      ║  🧠 ADHD TOOLS           ║
║  n new note  ║  SPC find/create  ║  p  Pomodoro              ║
║  f fleeting  ║  i   insert link  ║  T  focus timer           ║
║  l literature║  l   backlinks    ║  F  focus mode            ║
║  r research  ║  s   search text  ║  w  where was I?          ║
║  c concept   ║  b   backlinks    ║  u  brain dump            ║
║  m method.   ║  g   graph UI     ║  k  streak                ║
║  j daily     ║                   ║                           ║
╠══════════════╩═══════════════════╩══════════════════════════╣
║  📊 REVIEW: o orphans  ? stats  t add-tag  a add-alias       ║
╚══════════════════════════════════════════════════════════════╝
"
      ;; Capture
      ("n"   org-roam-node-find           "find/create")
      ("f"   rh/capture-fleeting          "fleeting")
      ("l"   rh/capture-literature        "literature")
      ("r"   rh/capture-research          "research")
      ("c"   rh/capture-concept           "concept")
      ("m"   rh/capture-methodology       "methodology")
      ("i"   rh/capture-interanimated     "interanimated")
      ("d"   org-roam-dailies-goto-today  "today's daily")
      ("D"   org-roam-dailies-capture-today "capture daily")
      ("j"   org-roam-dailies-goto-date   "goto date")
      ;; Navigate
      ("SPC" org-roam-node-find           "find note")
      ("I"   org-roam-node-insert         "insert link")
      ("L"   org-roam-buffer-toggle       "backlinks panel")
      ("s"   consult-org-roam-search      "full-text search")
      ("b"   consult-org-roam-backlinks   "backlinks search")
      ("B"   consult-org-roam-forward-links "forward links")
      ("g"   org-roam-ui-mode             "graph UI")
      ;; ADHD
      ("p"   org-pomodoro                 "Pomodoro")
      ("T"   rh/start-focus-timer         "focus timer")
      ("x"   rh/cancel-focus-timer        "cancel timer")
      ("F"   rh/focus-mode                "focus mode")
      ("z"   writeroom-mode               "writeroom")
      ("w"   rh/where-was-i               "where was I?")
      ("u"   rh/brain-dump                "brain dump")
      ("k"   rh/show-streak               "streak")
      ;; Review
      ("o"   rh/org-roam-find-orphans     "orphans")
      ("?"   rh/org-roam-stats            "stats")
      ("a"   org-roam-alias-add           "add alias")
      ("t"   org-roam-tag-add             "add tag")
      ("q"   nil                          "quit"))

    (global-set-key (kbd "C-c n") #'rh/hydra-org-roam/body)))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 3. Individual direct keybindings (always active, bypass the menu)
;;; ─────────────────────────────────────────────────────────────────────────────

;; These work even if you haven't opened the transient/hydra menu yet.

;; Most-used — single keystroke after C-c n:
(global-set-key (kbd "C-c n n")   #'org-roam-node-find)
(global-set-key (kbd "C-c n SPC") #'org-roam-node-find)
(global-set-key (kbd "C-c n i")   #'org-roam-node-insert)
(global-set-key (kbd "C-c n l")   #'org-roam-buffer-toggle)
(global-set-key (kbd "C-c n c")   #'org-roam-capture)
(global-set-key (kbd "C-c n g")   #'org-roam-graph)
(global-set-key (kbd "C-c n d")   #'org-roam-dailies-goto-today)
(global-set-key (kbd "C-c n D")   #'org-roam-dailies-capture-today)
(global-set-key (kbd "C-c n j")   #'org-roam-dailies-goto-date)

;; Search:
(global-set-key (kbd "C-c n s")   #'consult-org-roam-search)
(global-set-key (kbd "C-c n b")   #'consult-org-roam-backlinks)
(global-set-key (kbd "C-c n B")   #'consult-org-roam-forward-links)

;; Graph:
(global-set-key (kbd "C-c n G")   #'org-roam-ui-mode)

;; ADHD helpers:
(global-set-key (kbd "C-c n p")   #'org-pomodoro)
(global-set-key (kbd "C-c n T")   #'rh/start-focus-timer)
(global-set-key (kbd "C-c n F")   #'rh/focus-mode)
(global-set-key (kbd "C-c n z")   #'writeroom-mode)
(global-set-key (kbd "C-c n w")   #'rh/where-was-i)
(global-set-key (kbd "C-c n u")   #'rh/brain-dump)
(global-set-key (kbd "C-c n k")   #'rh/show-streak)

;; Review:
(global-set-key (kbd "C-c n o")   #'rh/org-roam-find-orphans)
(global-set-key (kbd "C-c n ?")   #'rh/org-roam-stats)

;; Tags & aliases:
(global-set-key (kbd "C-c n a")   #'org-roam-alias-add)
(global-set-key (kbd "C-c n t")   #'org-roam-tag-add)

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 4. Per-template capture shortcuts
;;; ─────────────────────────────────────────────────────────────────────────────

(defun rh/capture-fleeting ()
  "Capture a fleeting note directly (no template menu)."
  (interactive)
  (org-roam-capture- :node (org-roam-node-create)
                     :templates '(("f" "⚡ Fleeting thought" plain
                                   "%?"
                                   :if-new (file+head "fleeting/${slug}.org"
                                                      "#+title: ${title}\n#+created: %U\n#+filetags: :fleeting:\n\n")
                                   :unnarrowed t))))

(defun rh/capture-literature ()
  "Capture a literature note directly (no template menu)."
  (interactive)
  (org-roam-capture- :node (org-roam-node-create)
                     :templates '(("l" "📚 Literature note" plain
                                   "* Metadata\n- Author(s): %^{Author(s)}\n- Year: %^{Year}\n- DOI/URL: %^{DOI or URL}\n- Journal/Venue: %^{Journal or Venue}\n\n* Abstract/Summary\n\n%?\n\n* Key Ideas\n-\n\n* Methodology\n\n* Findings\n\n* Connections\n- Related to:\n- Builds on:\n- Contradicts:\n\n* My Thoughts\n\n* Quotes\n"
                                   :if-new (file+head "literature/${slug}.org"
                                                      "#+title: ${title}\n#+created: %U\n#+filetags: :literature:research:\n#+ROAM_REFS: ${ref}\n\n")
                                   :unnarrowed t))))

(defun rh/capture-research ()
  "Capture a research project note directly."
  (interactive)
  (org-roam-capture- :node (org-roam-node-create)
                     :templates '(("r" "🔬 Research project" plain
                                   "* Overview\n%?\n\n* Research Question(s)\n-\n\n* Hypotheses\n-\n\n* Methodology\n** Approach\n** Data Sources\n** Tools\n\n* Findings\n** Key Results\n** Null Results\n\n* Related Work\n-\n\n* Open Questions\n-\n\n* Next Steps\n** TODO\n"
                                   :if-new (file+head "projects/${slug}.org"
                                                      "#+title: ${title}\n#+created: %U\n#+filetags: :research:project:\n\n")
                                   :unnarrowed t))))

(defun rh/capture-concept ()
  "Capture a concept / evergreen idea note directly."
  (interactive)
  (org-roam-capture- :node (org-roam-node-create)
                     :templates '(("c" "💡 Concept / Idea" plain
                                   "* Definition\n%?\n\n* Why It Matters\n\n* Examples\n-\n\n* Connections\n-\n\n* Sources\n-\n"
                                   :if-new (file+head "concepts/${slug}.org"
                                                      "#+title: ${title}\n#+created: %U\n#+filetags: :concept:\n\n")
                                   :unnarrowed t))))

(defun rh/capture-methodology ()
  "Capture a methodology note directly."
  (interactive)
  (org-roam-capture- :node (org-roam-node-create)
                     :templates '(("m" "⚙️  Methodology" plain
                                   "* Description\n%?\n\n* When to Use\n\n* Steps / Protocol\n1.\n\n* Strengths\n-\n\n* Limitations\n-\n\n* Examples in Literature\n-\n\n* My Experience\n"
                                   :if-new (file+head "methodology/${slug}.org"
                                                      "#+title: ${title}\n#+created: %U\n#+filetags: :methodology:\n\n")
                                   :unnarrowed t))))

(defun rh/capture-interanimated ()
  "Capture an interanimated-papers note directly."
  (interactive)
  (org-roam-capture- :node (org-roam-node-create)
                     :templates '(("i" "🔗 Interanimated papers" plain
                                   "* Papers in Dialogue\n- Paper A:\n- Paper B:\n\n* Nature of Interaction\n- [ ] Builds upon\n- [ ] Contradicts\n- [ ] Extends\n- [ ] Synthesizes\n- [ ] Critiques\n\n* Key Points of Contact\n%?\n\n* Emergent Insights\n\n* Implications for My Research\n"
                                   :if-new (file+head "interanimated/${slug}.org"
                                                      "#+title: ${title}\n#+created: %U\n#+filetags: :interanimated:dialogue:\n\n")
                                   :unnarrowed t))))

;;; ─────────────────────────────────────────────────────────────────────────────
;;; 5. which-key descriptions (if which-key is installed)
;;; ─────────────────────────────────────────────────────────────────────────────

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c n"   "Org-Roam"
    "C-c n n" "find/create note"
    "C-c n i" "insert link"
    "C-c n l" "backlinks panel"
    "C-c n c" "capture (menu)"
    "C-c n g" "graph"
    "C-c n G" "graph UI (browser)"
    "C-c n d" "today's daily"
    "C-c n D" "capture into daily"
    "C-c n j" "jump to date"
    "C-c n s" "full-text search"
    "C-c n b" "backlinks search"
    "C-c n B" "forward links"
    "C-c n p" "Pomodoro"
    "C-c n T" "focus timer"
    "C-c n F" "focus mode"
    "C-c n z" "writeroom"
    "C-c n w" "where was I?"
    "C-c n u" "brain dump"
    "C-c n k" "show streak"
    "C-c n o" "find orphans"
    "C-c n ?" "stats"
    "C-c n a" "add alias"
    "C-c n t" "add tag"))

(provide 'init-org-roam-keybindings)
;;; init-org-roam-keybindings.el ends here
