---
name: paper-to-curriculum
description: Turn research papers into a full visual interactive curriculum—concept graph, nbformat notebooks, optional Manim + Next.js/react-three-fiber—using five expert agents and backend artifacts.
---

# Paper → visual curriculum

## When to use

- Inputs: one or more papers (PDF, URL, arXiv id, pasted text), learner level, depth, time budget, output mix (**Jupyter**, **web**, **both**).
- Goal: **deep understanding** via structured artifacts, not a shallow summary.

## Architecture (implementation-oriented)

- **Cursor**: Agent mode + **subagents** (parallel experts), **skills** (this file + `math-formula-visual`, `ui-ux-learning`), **rules** (`curriculum-agent`, `curriculum-quality`, `experience-design`).
- **Python backend** (under plugin `backend/` or copied into the user repo): ingest → concept graph → `nbformat` notebook build (`new_notebook`, `new_markdown_cell`, `new_code_cell`, `nbformat.write`).
- **Optional Manim**: programmatic math animations (install separately; see `backend/visuals/`).
- **Web**: Next.js (or similar) + **react-three-fiber** + **@react-three/drei** for interactive 3D/spatial scenes driven by `visual_specs.json`.

## Expert agent pipeline (strict order unless parallel noted)

1. **paper-ingestion-agent** — Structure only: sections, equations, definitions, algorithms, figure captions; build **concept graph** (nodes = concepts, edges = prerequisite / uses / extends). **Do not teach.**
2. **curriculum-architect** — `curriculum_outline.json`: modules → lessons → units; objectives, prerequisites, `paper_links`, `visuals_needed`, `concept_ids`.
3. **math-visual-designer** — For nontrivial formulas: LaTeX, **term-by-term** plain language, geometric/spatial intuition; `explanations.json` + `visual_specs.json` (static SVG, notebook plot, R3F scene, Manim scene).
4. **notebook-builder** — Run `backend/build_notebooks.py` (or equivalent) using **nbformat**; output `notebooks/module_*_lesson_*.ipynb` with placeholders for visuals.
5. **web-ui-builder** — Minimal macOS-like pages mirroring outline; KaTeX/MathJax; R3F `<Canvas>` scenes from `visual_specs.json`; follow **ui-ux-learning** + **experience-design**.

After delivery: **dashboard** (outline, notebook paths, web routes, CLI: `python -m venv …`, `pip install -r backend/requirements.txt`, `python backend/build_notebooks.py …`, `cd web && npm install && npm run dev`) and a **refinement prompt** (“What felt dense? More visual where?”).

## Artifact layout (per session)

Use `backend/artifacts/{session_id}/`:

| File | Producer | Purpose |
|------|-----------|---------|
| `paper_outline.json` | ingestion | Sections, extractions |
| `concept_graph.json` | ingestion | Graph of concepts |
| `curriculum_outline.json` | architect | Modules/lessons/units |
| `explanations.json` | math-visual | Per-formula teaching content |
| `visual_specs.json` | math-visual | Scene types, params, `preset` + optional `theme_id` |
| `schemas/visual_language.json` | — | Global motion, layout, three defaults (reference) |
| `schemas/themes/*` | — | CSS / Three / Manim / matplotlib tokens (reference) |
| `schemas/visual_spec_presets.json` | — | Reusable pedagogical visual templates (reference) |

## Step-by-step (agent checklist)

1. **Clarify** inputs: paths/URLs, audience, depth, Jupyter/web/both, time budget, target directory (user repo vs plugin copy).
2. **Ingestion**: read/run `backend/ingest_papers.py` when PDFs/paths exist; else build JSON from manual analysis; save artifacts above.
3. **Architect**: ensure no concept without prerequisites taught earlier; attach visuals list per lesson.
4. **Math/visual**: every nontrivial equation gets LaTeX + term-by-term + intuition + visual spec entry.
5. **Notebooks**: `python backend/build_notebooks.py --outline … --explanations … --out notebooks/`.
6. **Web**: scaffold or extend `web/`; map `curriculum_outline.json` to routes; implement scenes from specs.
7. **Summarize** + suggest next papers or partial re-runs (e.g. re-invoke math-visual only).

## Phased rollout (if user wants incremental)

1. Outline + concept graph only.  
2. + notebooks (`nbformat`).  
3. + Manim subset + embed GIF/MP4 in notebooks.  
4. + Next.js + R3F lesson pages.  
5. Multi-paper merge + parallel subagents for ingestion vs math.

## Guardrails

- Source fidelity: map claims to paper sections; label inference.
- Prefer **plugin `backend/`** scripts when the workspace is the plugin; when working in another repo, **copy** `backend/`, `schemas/`, and `web/` templates or path to them explicitly.
- Do not over-configure: tighten rules/skills only after repeated agent mistakes.
