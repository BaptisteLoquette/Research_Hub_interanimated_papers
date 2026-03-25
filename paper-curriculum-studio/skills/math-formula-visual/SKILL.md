---
name: math-formula-visual
description: For each nontrivial formula or algorithm—LaTeX, term-by-term explanation, spatial intuition, and visual_specs entries (Manim, plots, react-three-fiber).
---

# Math formula & visual design

## Trigger

Curriculum work has identified equations, algorithms, or figures that need teaching depth—used standalone or inside **paper-to-curriculum** after `concept_graph.json` exists.

## Outputs

Append or create:

- **`explanations.json`**: keyed by `concept_id` or stable `formula_id`:
  - `title`, `latex`, `plain_explanation`, `term_by_term` (structured string or array of `{symbol, meaning}`), `intuition_geometric` (optional), `code_example` (optional notebook snippet).
- **`visual_specs.json`**: array of objects:
  - `id`, `lesson_id`, `type` ∈ `static_svg` | `jupyter_plot` | `manim_scene` | `react_three_fiber` | `embed_video`
  - `description`, `parameters` (include **`preset`** from `schemas/visual_spec_presets.json` when applicable), optional **`theme_id`** (from `schemas/themes/index.json`)
  - `manim_class` / `tsx_component` name, `data_refs`
- **Themes**: pick a coherent **`theme_id`** per lesson or per spec so web CSS, R3F (`three` block in theme JSON), Manim, and matplotlib stay aligned—use `visual_spec_presets.json` → `default_theme_id` as a starting point.

## Workflow

1. List all **display equations** and nontrivial inline math from the paper outline.
2. For each: render **LaTeX** in markdown-friendly form (`$$...$$` in notebooks; KaTeX on web).
3. **Term-by-term**: every symbol and operator explained in plain language (assume strong general technical background, topic may be new).
4. **Spatial / physical intuition** when honest (vector fields, manifolds, probability as area/volume, circuits as graphs, etc.).
5. Choose **one primary visual modality** per formula unless complexity demands layered (default static → interactive upgrade path).
6. **Manim**: emit a `Scene` subclass sketch or full file under `backend/visuals/`; document render command `manim -pqh path SceneName`.
7. **R3F**: specify camera, lights, meshes/instancing, `OrbitControls`, and which props tie to lesson parameters.

## Quality bar

- No hand-waving: if intuition is speculative, label it.
- Align with **experience-design**: calm layout around math; long breakdowns in **collapsible** UI on web or appendix cells in notebooks.

## Handoff

- **notebook-builder** consumes `explanations.json`.
- **web-ui-builder** consumes `visual_specs.json` and formula breakdown components.
