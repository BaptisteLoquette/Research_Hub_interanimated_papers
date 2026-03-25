# Paper Curriculum Studio

Cursor plugin: **multi-agent**, **implementation-oriented** pipeline from **research papers** to **minimal, macOS-like**, **spatial** learning—**Jupyter** (`nbformat`), optional **Manim**, and **Next.js + react-three-fiber** web lessons. Topics include generative electronics, agentic systems, world models, reasoning, RAG, EDA, etc., with **source fidelity** and **term-by-term math** teaching.

## Installation

Local plugin path:

`~/.cursor/plugins/local/paper-curriculum-studio/`

Reload Cursor if the plugin does not appear.

## Architecture

| Layer | Role |
|-------|------|
| **Cursor** | Agent mode, subagents, skills, rules |
| **Python `backend/`** | `ingest_papers.py` (stub → extend), `build_notebooks.py` (**nbformat**), `visuals/` (optional **Manim**) |
| **`schemas/`** | JSON conventions + `example_curriculum_outline.json` |
| **`notebooks/`** | Default output target for generated `.ipynb` |
| **`web/`** | README, `styles/curriculum-themes.css` (generated), `themes/*` helpers, `LessonScene.example.tsx` |
| **`schemas/themes/`** | 8 minimalist themes (CSS vars, Three, Manim, matplotlib) + `index.json` |
| **`schemas/visual_language.json`** | Motion, type scale, R3F defaults |
| **`schemas/visual_spec_presets.json`** | 12+ pedagogical visual presets |

## Skills

| Skill | Purpose |
|-------|---------|
| **paper-to-curriculum** | End-to-end pipeline, artifact layout, agent order, phased rollout |
| **math-formula-visual** | `explanations.json` + `visual_specs.json` |
| **ui-ux-learning** | Three-pane layout, keyboard-first, chunked copy |
| **orchestrate-deep-curriculum** | Alias → delegates to **paper-to-curriculum** |

## Agents (experts)

1. **paper-ingestion-agent** — structure + concept graph only  
2. **curriculum-architect** — `curriculum_outline.json`  
3. **math-visual-designer** — LaTeX, term-by-term, Manim/R3F specs  
4. **notebook-builder** — programmatic notebooks  
5. **web-ui-builder** — Next + R3F lesson UI  

## Rules

- **curriculum-agent** — mission, math rigor, artifact order, `backend/`/`web/` globs  
- **curriculum-quality** — sourcing, notebook structure  
- **experience-design** — minimal UI, ADHD-friendly, spatial three-pane, keyboard  

## Commands

- **Start curriculum from paper** — prompt template + CLI hints  

## Repository layout (inside plugin)

```text
paper-curriculum-studio/
  .cursor-plugin/plugin.json
  rules/
  skills/
  agents/
  commands/
  backend/
    ingest_papers.py
    build_notebooks.py
    visuals/
    artifacts/
  schemas/
  notebooks/
  web/
```

Copy `backend/`, `schemas/`, and `web/` into a dedicated project repo when you want isolation from the plugin install.

## Build roadmap (phased)

1. **Foundation** — rules + **paper-to-curriculum** outline-only run.  
2. **Notebooks** — `pip install -r backend/requirements.txt`; `build_notebooks.py`.  
3. **Manim** — optional `requirements-visual.txt`; scenes in `backend/visuals/`.  
4. **Web** — Next.js app; map `curriculum_outline.json` to routes; R3F from `visual_specs.json`.  
5. **Multi-paper** — merge graphs; parallel ingestion vs math agents.  

## Design philosophy

Minimal, 0-friction, **macOS-like** surfaces; **visual/spatial** hierarchy; **ADHD-friendly** chunking; **technical depth** in collapsible layers. See **experience-design** and **ui-ux-learning**.

## License

MIT — see `LICENSE`.
