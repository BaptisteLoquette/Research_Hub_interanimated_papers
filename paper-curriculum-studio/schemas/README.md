# JSON schemas (conventions)

## `paper_outline.json`

- `title`, `abstract`, `sections` (map of section key → list of bullet summaries or paragraphs).
- `equations`: `{ "id", "latex", "section" }[]`
- `definitions`, `algorithms`, `figures`: arrays with `id` + content/caption fields as needed.
- `warnings`: string array for uncertain OCR/extraction.

## `concept_graph.json`

```json
{
  "nodes": [{ "id": "latent-z", "label": "Latent variable z", "section_refs": ["methods"] }],
  "edges": [{ "from": "prior", "to": "latent-z", "relation": "prerequisite" }]
}
```

## `curriculum_outline.json`

```json
{
  "modules": [
    {
      "id": "foundations",
      "title": "Foundations",
      "lessons": [
        {
          "id": "bayes-basics",
          "title": "Bayes in generative models",
          "objectives": ["Interpret prior and likelihood"],
          "prerequisites": [],
          "paper_links": ["introduction"],
          "visuals_needed": ["bayes-area"],
          "concept_ids": ["bayes-rule"]
        }
      ]
    }
  ]
}
```

## `explanations.json`

Map `concept_id` → `{ "title", "latex", "plain_explanation", "term_by_term", "intuition_geometric?", "code_example?" }`.

## `visual_specs.json`

Array of objects:

- Required: `id`, `lesson_id`, `type`, `description`
- Optional: `theme_id` (see `themes/index.json`), `parameters` (often includes `preset` from `visual_spec_presets.json`), `manim_class`, `tsx_component`, `data_refs`

`type` is one of: `static_svg`, `jupyter_plot`, `manim_scene`, `react_three_fiber`, `embed_video`.

## Themes (`schemas/themes/`)

- **`index.json`** — catalog + `default_theme_id`.
- **`<id>.json`** — `css` variables (`--cur-*`), `three` (background, fog, lights), `manim` hexes, `matplotlib` rc strings, `series_colors`.
- **CSS output**: `web/styles/curriculum-themes.css` (regenerate via `backend/generate_theme_css.py`).

## `visual_language.json`

Global motion, layout, typography scale, `three_defaults`, `jupyter_plot`, and `manim_defaults` shared across themes.

## `visual_spec_presets.json`

Named pedagogical presets (`vector_field_2d`, `graph_concept`, `agent_react_loop`, …) with `visual_spec_template`, hints per modality, and `default_theme_id`.

## Example bundle

- `example_curriculum_outline.json` — minimal outline with one lesson referencing `marginal-p-x`.
- `example_explanations.json` — matching explanation + code stub for `build_notebooks.py` demos.
- `example_visual_specs.json` — sample entries with `theme_id` + `preset` parameters.
