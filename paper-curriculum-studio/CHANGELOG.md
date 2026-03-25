# Changelog

## 0.3.1

- **Themes**: 8 JSON themes (`schemas/themes/`), generated `web/styles/curriculum-themes.css`, `backend/generate_theme_css.py`, `visuals/theme_loader.py` for Manim/matplotlib.
- **Visual config**: `visual_language.json`, `visual_spec_presets.json` (12 presets), `example_visual_specs.json`.
- **Web helpers**: `web/themes/` TypeScript utilities for R3F + `data-cur-theme`.

## 0.3.0

- Blueprint upgrade: skill **paper-to-curriculum** (+ **math-formula-visual**, **ui-ux-learning**); five expert agents (ingestion, architect, math/visual, notebook, web).
- Rule **curriculum-agent**; expanded **experience-design** (three-pane, paragraph cap, keyboard, breadcrumbs).
- **Backend**: `ingest_papers.py`, `build_notebooks.py` (nbformat), `visuals/equation_scene.py` (Manim example), `requirements.txt`.
- **schemas/**, **web/** example R3F component, **notebooks/** placeholder; README architecture + phased roadmap.
- Removed legacy agents superseded by the five-expert split.

## 0.2.0

- Added `experience-design` rule (minimal, macOS-like, spatial, ADHD-friendly, research-dense-on-demand).
- Wired UX defaults through orchestration skill, visual tutor, notebook author, architect, README, and start command.

## 0.1.0

- Initial scaffold: orchestration skill, four specialized agents, curriculum quality rule, start command.
