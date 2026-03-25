---
name: ui-ux-learning
description: Minimal macOS-like learning UIs—three-pane spatial layout, keyboard-first navigation, chunked copy, progress landmarks—for web and interactive curriculum surfaces.
---

# UI/UX for learning surfaces

## Trigger

Building or reviewing **web** (or hybrid) curriculum UI: lesson pages, interactives, dashboards.

## Stack assumptions (when implementing)

- **Next.js** + React + Tailwind (or equivalent) for fast, neutral chrome.
- **react-three-fiber** for declarative Three.js scenes; **@react-three/drei** for `OrbitControls`, helpers.
- Formulas: **KaTeX** or **MathJax**.

## Layout (working memory / spatial)

**Stable three-pane** (desktop); collapse to single column on small screens with same **order**: outline → main → details.

| Region | Content |
|--------|---------|
| **Left** | Narrow TOC: modules → lessons → current unit. Keyboard navigable. |
| **Center** | Primary visual + short explanation. One focal subject. |
| **Right** | Optional: term-by-term formula panel, code peek, citations—**collapsible**, default closed or narrow. |

Do **not** reshuffle chrome between steps. Match **experience-design** (one accent, neutrals, system-adjacent type).

## Copy rules (ADHD + technical)

- **Hard cap**: no markdown paragraph longer than **four short lines** without a break; prefer headings, numbered steps, or bullets.
- **One primary interaction** per view (e.g. “Run”, “Next”, “Expand proof”).
- **Progress**: visible breadcrumb `Module → Lesson → Unit`; simple checkmarks for completion—no gamified noise.

## Keyboard-first

- Implement or document: `J`/`K` or arrows to move between units when in web app; focus rings on all controls.
- Notebooks: single setup cell; document “run all above” / section run patterns for the user’s environment.

## Anti-patterns

- Equal-weight dashboard tiles competing for attention.
- Autoplay motion + required reading simultaneously.
- Icon-only critical actions without text labels.

## Cross-links

- Global motion, color, and progressive disclosure: **experience-design** rule.
- Mission + math rigor: **curriculum-agent** rule.
