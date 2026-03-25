# Backend — paper → artifacts → notebooks

## Setup

```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

Optional Manim (heavy): uncomment in `requirements-visual.txt`, then `pip install -r requirements-visual.txt`.

## Scripts

| Script | Purpose |
|--------|---------|
| `ingest_papers.py` | Stub pipeline: accepts `--session` and optional `--pdf`; writes `artifacts/{session}/paper_outline.json` + `concept_graph.json` (template or minimal parse). Extend with your PDF stack. |
| `build_notebooks.py` | Reads `curriculum_outline.json` + `explanations.json`, emits `.ipynb` via **nbformat**. |
| `generate_theme_css.py` | Builds `../web/styles/curriculum-themes.css` from `../schemas/themes/*.json`. Run after editing theme tokens. |

## Themes (Python)

- `visuals/theme_loader.py` — `load_theme(theme_id)`, `manim_colors()`, `apply_matplotlib_theme()` for notebooks that match the web CSS themes.

## Artifacts

Session-scoped JSON under `artifacts/<session_id>/`. See `../schemas/README.md` for shapes.
