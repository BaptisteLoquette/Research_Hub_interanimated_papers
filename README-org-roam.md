# 🧠 Research Hub Org-Roam Setup

> **Complete, production-ready Org-Roam configuration optimised for ADHD,
> visual/outliner-first note-takers, and technical researchers.**

---

## Table of Contents

1. [What This Is](#what-this-is)
2. [Installation Prerequisites](#installation-prerequisites)
3. [Step-by-Step Setup](#step-by-step-setup)
4. [File Structure](#file-structure)
5. [Keybinding Cheat Sheet](#keybinding-cheat-sheet)
6. [Workflow Guide for ADHD Users](#workflow-guide-for-adhd-users)
7. [Workflow Guide for Researchers](#workflow-guide-for-researchers)
8. [Interanimated Papers Workflow](#interanimated-papers-workflow)
9. [Template Reference](#template-reference)
10. [FAQ & Troubleshooting](#faq--troubleshooting)

---

## What This Is

This repository ships a **complete Org-Roam second-brain** configuration split
into focused modules:

| File | Purpose |
|------|---------|
| `.emacs.d/init-org-roam.el` | Core Org-Roam config, capture templates, DB sync |
| `.emacs.d/init-org-roam-ui.el` | Visual rendering (org-modern, graph UI, fonts) |
| `.emacs.d/init-org-roam-adhd.el` | ADHD helpers: Pomodoro, streaks, auto-save, focus mode |
| `.emacs.d/init-org-roam-research.el` | Research workflows: literature notes, interanimated papers |
| `.emacs.d/init-org-roam-keybindings.el` | Unified `C-c n` keybinding map + transient/hydra menu |
| `.emacs.d/init.el` | Master loader — loads all modules in the right order |
| `org/templates/*.org` | Org capture template files |
| `.dir-locals.el` | Auto-sets `org-roam-directory` when you open the repo |

---

## Installation Prerequisites

### Required

| Requirement | Version | Notes |
|-------------|---------|-------|
| **GNU Emacs** | 29+ | 30+ recommended for best performance |
| **SQLite** | any | Usually bundled with your OS |
| **ripgrep** (`rg`) | any | For `consult-org-roam` full-text search |
| **Git** | any | For version-controlling your notes |

### Install Emacs 29+

```bash
# macOS (Homebrew)
brew install emacs --cask     # or: brew install emacs

# Ubuntu / Debian
sudo add-apt-repository ppa:kelleyk/emacs
sudo apt install emacs29

# Windows
# Download from https://www.gnu.org/software/emacs/download.html
# Or use Scoop: scoop install emacs

# Fedora / RHEL
sudo dnf install emacs
```

### Install ripgrep

```bash
# macOS
brew install ripgrep

# Ubuntu / Debian
sudo apt install ripgrep

# Windows
scoop install ripgrep
# or: winget install BurntSushi.ripgrep.MSVC
```

### Optional but recommended

| Package | Purpose |
|---------|---------|
| **LaTeX** (TeX Live / MacTeX) | PDF export from Org files |
| **Zotero + Better BibTeX** | Automatic BibTeX export for citations |
| **pdf-tools** (Emacs package) | In-Emacs PDF viewing and annotation |
| **org-noter** (Emacs package) | PDF ↔ Org annotation linking |

---

## Step-by-Step Setup

### Step 1 — Clone the repository

```bash
git clone https://github.com/BaptisteLoquette/Research_Hub_interanimated_papers.git
cd Research_Hub_interanimated_papers
```

### Step 2 — Configure package archives

Add to your `~/.emacs.d/init.el` (if not already present):

```elisp
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/") t)
(package-initialize)
```

### Step 3 — Load the Research Hub configuration

**Option A — Dedicated Emacs instance** (cleanest):

```bash
emacs --init-directory /path/to/Research_Hub_interanimated_papers/.emacs.d/
```

**Option B — Add to your existing init.el**:

```elisp
;; In your ~/.emacs.d/init.el:
(load "/path/to/Research_Hub_interanimated_papers/.emacs.d/init.el")
```

**Option C — Use `.dir-locals.el` (project-local)**:

Open any file in the repository. Emacs will apply `.dir-locals.el` automatically,
setting `org-roam-directory` to the project's `org/` folder. Then run:

```
M-x load-file RET .emacs.d/init.el RET
```

### Step 4 — Install packages

Once Emacs is running with the config loaded:

```
M-x rh/install-packages RET
```

This installs all required packages from MELPA. Wait for it to finish (usually
1–2 minutes on first run).

### Step 5 — Build the database

```
M-x org-roam-db-sync RET
```

### Step 6 — Verify the setup

```
C-c n ?    →  Should show "📊 Org-Roam — Notes: 0 | Links: 0 | Tags: 0 | Orphans: 0"
C-c n n    →  Should open a node-find dialog
C-c n d    →  Should open/create today's daily note
```

---

## File Structure

After setup, your `org/` directory will look like this:

```
org/
├── daily/              ← Journal entries (one file per day)
│   └── 2026-04-07.org
├── literature/         ← Paper and book notes
│   └── author-2024-title.org
├── fleeting/           ← Quick captures, inbox
│   └── rough-idea.org
├── projects/           ← Research projects
│   └── my-project.org
├── concepts/           ← Evergreen concept notes
│   └── interanimation.org
├── methodology/        ← Method descriptions
│   └── thematic-analysis.org
├── interanimated/      ← Paper dialogue notes
│   └── paper-a-vs-paper-b.org
├── templates/          ← Capture template files (not indexed)
│   ├── literature-note.org
│   ├── research-project.org
│   ├── concept.org
│   ├── methodology.org
│   └── interanimated.org
├── research-questions.org ← Central research question tracker
└── reading-list.org       ← Reading list
```

---

## Keybinding Cheat Sheet

All commands live under the **`C-c n`** prefix.  
Press `C-c n m` to open the interactive menu (transient/hydra).

### 📝 Capture

| Key | Action | When to use |
|-----|--------|-------------|
| `C-c n m` | Open **command menu** (all commands) | Discoverability / new users |
| `C-c n n` | Find or **create** a note | THE key — use constantly |
| `C-c n c` | Capture menu (choose template) | When you want a specific template |
| `C-c n d` | Go to **today's** daily | Morning intentions, daily log |
| `C-c n D` | **Capture** into today's daily | Quick timestamped entry |
| `C-c n j` | Jump to a **specific date** | Reviewing a past day |
| `C-c n u` | **Brain dump** → today's daily | When head is full |

### 🔍 Navigate & Search

| Key | Action |
|-----|--------|
| `C-c n i` | **Insert** a link to another note |
| `C-c n l` | Toggle **backlinks** panel |
| `C-c n s` | **Full-text search** (ripgrep) |
| `C-c n b` | Search **backlinks** |
| `C-c n B` | Search **forward links** |
| `C-c n G` | Open **knowledge graph** in browser |

### 🔬 Research Tools

| Key | Action |
|-----|--------|
| `M-x rh/new-literature-note` | Create a literature note with prompts |
| `M-x rh/new-interanimated-note` | Create an interanimated-papers note |
| `M-x rh/research-questions` | Open research question tracker |
| `M-x rh/reading-list` | Open reading list |
| `M-x rh/add-to-reading-list` | Add paper to reading list |
| `M-x rh/export-to-markdown` | Export current note to Markdown |
| `M-x rh/export-to-pdf` | Export current note to PDF |
| `M-x rh/find-notes-by-tag` | List notes with a specific tag |

### 🧠 ADHD & Focus

| Key | Action |
|-----|--------|
| `C-c n p` | Start **Pomodoro** timer (25 min) |
| `C-c n T` | Start **custom focus** timer |
| `C-c n F` | Toggle **focus mode** (hides modeline, maximises buffer) |
| `C-c n z` | Toggle **Writeroom** distraction-free mode |
| `C-c n w` | **Where was I?** — recently visited notes |
| `C-c n k` | Show **capture streak** (🔥) |

### 📊 Review & Maintenance

| Key | Action |
|-----|--------|
| `C-c n o` | Find **orphan notes** (no backlinks) |
| `C-c n ?` | Show **stats** (note/link/tag count) |
| `C-c n a` | Add **alias** to current node |
| `C-c n t` | Add **tag** to current node |

---

## Workflow Guide for ADHD Users

### The Core Loop (10 seconds per capture)

```
Have a thought → C-c n n → type title → RET → type idea → C-c C-c
```

That's it. Do not organise. Do not file. Just capture.

### Morning Routine (5 minutes)

1. `C-c n d` — Open today's daily note
2. Write your **1–3 intentions** for the day
3. `C-c n w` — See where you left off yesterday (Where was I?)
4. `C-c n p` — Start a Pomodoro to kickstart the first session

### During the Day

- **New idea** → `C-c n n` (type title, write, `C-c C-c`)
- **Reading a paper** → `M-x rh/new-literature-note`
- **Making a connection** → `C-c n i` while writing to link notes
- **Distracted** → `C-c n F` to enter focus mode
- **Head too full** → `C-c n u` for a brain dump into the daily

### End of Day (5 minutes)

1. `C-c n d` — Daily note: write what you accomplished
2. `C-c n k` — Check your streak (motivation boost!)

### Weekly Review (20 minutes)

1. `C-c n o` — Find orphan notes → link them or archive them
2. `M-x rh/research-questions` — Review open research questions
3. `M-x rh/reading-list` — Update reading list status
4. `C-c n G` — Browse the graph — spot clusters and gaps

### ADHD-Specific Settings Explained

| Feature | What it does | Why it helps |
|---------|-------------|--------------|
| Auto-save every 30s | Saves all modified Org-Roam buffers silently | Never lose a thought |
| Focus mode | Hides modeline, maximises window | Removes visual noise |
| Streak tracker | Counts consecutive capture days | Dopamine-friendly feedback |
| "Where was I?" | Lists recently visited notes | Recovers context after interruption |
| Session reminder | Message after 90 min of work | Prevents hyperfocus burnout |
| Brain dump | One key → daily note entry | Offloads working memory instantly |
| Auto-show backlinks | Backlinks panel on right | Serendipitous connections |

---

## Workflow Guide for Researchers

### Reading a New Paper

1. `M-x rh/add-to-reading-list` — Add to the queue
2. When ready to read: `M-x rh/new-literature-note` — creates structured note
3. Fill in: abstract, key ideas, methodology, findings, connections
4. `C-c n i` — Link to related concept/project notes while reading
5. After reading: mark as DONE in reading list

### Building a Literature Review

1. Use `M-x rh/find-notes-by-tag` with tag `literature`
2. Create a project note (`C-c n c` → `r`) for the review
3. `C-c n i` — Insert links to all relevant literature notes
4. Use the backlinks panel to see which notes connect to your project
5. `C-c n G` — Visualize the cluster in the graph

### Tracking Research Questions

```
M-x rh/add-research-question   →  Add a new question
M-x rh/research-questions      →  Review and update status
```

Questions move through: `TODO` → `IN-PROGRESS` → `DONE` / `CANCELLED`

### Source Block Execution

Execute code directly in your notes:

```org
#+begin_src python :results output
import numpy as np
print(np.random.normal(0, 1, 5))
#+end_src
```

Press `C-c C-c` on the block to run it. Results appear inline.

### Citation Management

If you use Zotero with Better BibTeX:

1. Export your library as Better BibTeX `.bib` file
2. Set `(setq org-cite-global-bibliography '("/path/to/library.bib"))`
3. Insert citations with `C-c C-x @` or `M-x org-cite-insert`
4. Uncomment the `org-roam-bibtex` block in `init-org-roam.el` for full integration

---

## Interanimated Papers Workflow

"Interanimated papers" are papers that are in active intellectual dialogue —
they build on, respond to, contradict, or synthesise each other.

### Creating an Interanimation Note

```
M-x rh/new-interanimated-note
```

You'll be prompted for:
- Title (describe the dialogue, e.g., "Vygotsky vs Piaget on cognitive development")
- Paper A (title or `[[link]]`)
- Paper B (title or `[[link]]`)
- Interaction type (builds-upon / contradicts / extends / synthesizes / critiques)

### The Interanimated Template

Each note captures:

1. **Papers in Dialogue** — with links to their literature notes
2. **Nature of Interaction** — checkboxes for the type of relationship
3. **Publication Timeline** — when each paper appeared
4. **Key Points of Contact** — shared concepts, agreements, disagreements
5. **Emergent Insights** — ideas that only appear when reading them together
6. **Gaps in the Dialogue** — what they collectively fail to address
7. **Implications for My Research** — so-what for you

### Visualizing the Interanimation Network

```
C-c n G    →  Opens org-roam-ui in browser
```

In the browser, filter by tag `:interanimated:` to see only the dialogue network.
The graph shows how papers cluster and which concepts are most densely connected.

### Example Workflow

```
1. Read Paper A  →  M-x rh/new-literature-note → "Situated Learning (Lave & Wenger 1991)"
2. Read Paper B  →  M-x rh/new-literature-note → "Activity Theory (Engeström 1987)"
3. Notice they dialogue  →  M-x rh/new-interanimated-note
4. Title: "Activity Theory extends Situated Learning"
5. Fill in: Paper A = [[Situated Learning]], Paper B = [[Activity Theory]]
6. Nature: [X] Extends
7. Write: Key Points of Contact, Emergent Insights, Implications
8. Link both literature notes back to this interanimated note: C-c n i
```

---

## Template Reference

### Literature Note (`org/templates/literature-note.org`)

```
#+title: ${title}
#+filetags: :literature:research:
#+ROAM_REFS: ${ref}

* Metadata          ← author, year, DOI, venue
* Abstract/Summary  ← your summary (not the abstract verbatim)
* Key Ideas         ← bullet points of the main contributions
* Methodology       ← how they did it
* Findings          ← what they found (including null results)
* Connections       ← related to / builds on / contradicts
* My Thoughts       ← strengths, weaknesses, relevance to you
* Quotes            ← verbatim quotes with references
```

### Research Project (`org/templates/research-project.org`)

```
#+title: ${title}
#+filetags: :research:project:

* Research Question(s)
* Hypotheses
* Methodology       ← approach, data, tools, timeline
* Literature Review
* Findings
* Open Questions
* Next Steps
```

### Concept Note (`org/templates/concept.org`)

```
#+title: ${title}
#+filetags: :concept:

* One-Line Definition    ← forces clarity
* Full Definition
* Intuition / Mental Model
* Formal Statement
* Examples              ← concrete + counter-example
* Common Misconceptions
* Connections           ← is-a / relates-to / contrasts-with
* Sources
```

### Interanimated Papers (`org/templates/interanimated.org`)

```
#+title: ${title}
#+filetags: :interanimated:dialogue:

* Papers in Dialogue
* Nature of Interaction  ← checkboxes
* Publication Timeline
* Key Points of Contact
* Emergent Insights
* Gaps in the Dialogue
* Implications for My Research
```

---

## FAQ & Troubleshooting

### "I get an error about org-roam not being installed"

Run `M-x rh/install-packages` to install all required packages, then restart Emacs.

### "The database feels slow"

Run `C-u M-x org-roam-db-sync` (note the `C-u` prefix) to do a full rebuild.

### "I accidentally deleted a note"

Commit your `org/` directory to Git daily (or use `git auto-commit` / a cron job):

```bash
cd /path/to/repo
git add org/ && git commit -m "Daily notes backup $(date +%Y-%m-%d)"
```

### "The graph in the browser looks empty"

1. Make sure `org-roam-ui` is enabled: `M-x org-roam-ui-mode`
2. Check that notes are in `org/` and have been synced: `M-x org-roam-db-sync`
3. Open a note, then press `C-c n G`

### "Pomodoro sounds don't work"

Requires `aplay` (Linux) or `afplay` (macOS). Install with:

```bash
# Ubuntu
sudo apt install alsa-utils

# macOS — already included
```

If sounds are not important to you:
```elisp
(setq org-pomodoro-play-sounds nil)
```

### "I want to use Zotero for citations"

1. Install [Zotero](https://www.zotero.org/) and the
   [Better BibTeX](https://retorque.re/zotero-better-bibtex/) plugin
2. Export library: Zotero → File → Export Library → Better BibTeX
3. Set auto-export to update the `.bib` file on every change
4. In Emacs: `(setq org-cite-global-bibliography '("~/path/to/library.bib"))`
5. Uncomment `org-roam-bibtex` block in `.emacs.d/init-org-roam.el`

### "I want to sync notes across devices"

**Option A — Git** (recommended for technical users):
```bash
cd org/
git init && git remote add origin <your-private-repo>
# Add a cron job or alias to commit + push daily
```

**Option B — Syncthing** (easiest, P2P, no cloud):
- Install on all devices, point at the `org/` directory

**Option C — iCloud / Dropbox / OneDrive**:
- Move the `org/` directory to your cloud folder
- Update `org-roam-directory` accordingly

### "How do I reset the configuration?"

Delete the SQLite database and rebuild:
```bash
rm org/.org-roam.db
```
Then: `M-x org-roam-db-sync`

---

## Design Philosophy

This configuration is built on three principles:

**1. Capture first, organize never.**  
Write the idea. Link it. Move on. Structure emerges from connections, not folders.

**2. Reduce friction at every step.**  
If it takes more than 2 keystrokes, it won't happen when you're in flow.
Every capture template has a single-letter shortcut. The most common action
(`C-c n n`) opens both find *and* create.

**3. The graph is the organization.**  
Folders are for files. Links are for knowledge. Use `C-c n G` to see how
your ideas actually connect — this is more useful than any folder hierarchy.

---

*Built for [Research_Hub_interanimated_papers](https://github.com/BaptisteLoquette/Research_Hub_interanimated_papers) · Powered by [Org-Roam](https://www.orgroam.com/)*
