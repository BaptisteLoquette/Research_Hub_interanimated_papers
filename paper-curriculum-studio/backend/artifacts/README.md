# Artifacts directory

Per-session JSON consumed by the pipeline. Created by agents + `ingest_papers.py`.

Suggested layout:

```text
artifacts/
  <session_id>/
    paper_outline.json
    concept_graph.json
    curriculum_outline.json   # from curriculum-architect
    explanations.json         # from math-visual-designer
    visual_specs.json       # from math-visual-designer
```

See `../../schemas/README.md` for field conventions.
