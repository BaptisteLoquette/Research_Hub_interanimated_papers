---
name: Start curriculum from paper
description: Run the full paper→curriculum pipeline—artifacts, nbformat notebooks, optional Manim and Next.js/react-three-fiber.
---

# Start curriculum from paper

Use when beginning a **paper → visual curriculum** project (Jupyter, web, or both).

## Prompt template

1. Topic and audience (assumed background).
2. Paper paths, URLs, or arXiv ids.
3. Depth, time budget, deliverables: **Jupyter** / **web** / **both**; optional Manim, Next.js.
4. Workspace directory (project repo). If using the plugin’s bundled backend, say so and pass `--session`.

## Agent order (subagents / roles)

1. **paper-ingestion-agent** → `paper_outline.json`, `concept_graph.json`
2. **curriculum-architect** → `curriculum_outline.json`
3. **math-visual-designer** → `explanations.json`, `visual_specs.json`
4. **notebook-builder** → `python backend/build_notebooks.py --outline … --explanations … --out notebooks/`
5. **web-ui-builder** → Next.js pages + R3F from `visual_specs.json`

## Skills

- Primary: **`paper-to-curriculum`**
- Supporting: **`math-formula-visual`**, **`ui-ux-learning`**
- Alias: **`orchestrate-deep-curriculum`** (points at the same pipeline)

## Rules

**curriculum-agent**, **curriculum-quality**, **experience-design**.

## Backend quick start

```bash
cd path/to/paper-curriculum-studio/backend   # or copied backend/ in your repo
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python ingest_papers.py --session mysession [--pdf /path/to/paper.pdf]
python build_notebooks.py --outline ../schemas/example_curriculum_outline.json --explanations /path/to/explanations.json --out ../notebooks
```

Replace paths with your real `curriculum_outline.json` and `explanations.json` once agents produce them.
