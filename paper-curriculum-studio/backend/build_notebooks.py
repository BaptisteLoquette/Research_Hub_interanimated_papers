#!/usr/bin/env python3
"""
Build Jupyter notebooks from curriculum_outline.json + explanations.json using nbformat.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import nbformat
from nbformat.v4 import new_code_cell, new_markdown_cell, new_notebook


def build_lesson_notebook(lesson_spec: dict, out_path: Path) -> None:
    nb = new_notebook()
    cells: list = []

    title = f"# {lesson_spec['title']}\n\n"
    objectives = "\n".join(f"- {obj}" for obj in lesson_spec.get("objectives", []))
    intro_md = f"{title}**Objectives**\n\n{objectives}\n"
    cells.append(new_markdown_cell(intro_md))

    for section in lesson_spec.get("sections", []):
        if section["type"] == "markdown":
            cells.append(new_markdown_cell(section["content"]))
        elif section["type"] == "code":
            cells.append(new_code_cell(section["content"]))

    nb["cells"] = cells
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as f:
        nbformat.write(nb, f)


def build_all_notebooks(
    curriculum_outline_path: Path,
    explanations_path: Path,
    output_dir: Path,
) -> None:
    outline = json.loads(curriculum_outline_path.read_text(encoding="utf-8"))
    explanations = json.loads(explanations_path.read_text(encoding="utf-8"))

    for module in outline.get("modules", []):
        mod_id = module.get("id", "module")
        for lesson in module.get("lessons", []):
            lesson_id = lesson["id"]
            sections: list[dict] = []
            for concept_id in lesson.get("concept_ids", []):
                ex = explanations.get(concept_id, {})
                if not ex:
                    continue
                term = ex.get("term_by_term", "")
                latex = ex.get("latex", "")
                title = ex.get("title", concept_id)
                plain = ex.get("plain_explanation", "")
                md = (
                    f"## {title}\n\n{plain}\n\n"
                    f"$$\n{latex}\n$$\n\n"
                    f"{term}\n"
                )
                sections.append({"type": "markdown", "content": md})
                if "code_example" in ex:
                    sections.append({"type": "code", "content": ex["code_example"]})

            lesson_spec = {
                "title": lesson["title"],
                "objectives": lesson.get("objectives", []),
                "sections": sections,
            }
            out = output_dir / f"module_{mod_id}_lesson_{lesson_id}.ipynb"
            build_lesson_notebook(lesson_spec, out)
            print(f"Wrote {out}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Build notebooks from curriculum JSON")
    parser.add_argument("--outline", required=True, type=Path, help="curriculum_outline.json")
    parser.add_argument("--explanations", required=True, type=Path, help="explanations.json")
    parser.add_argument("--out", required=True, type=Path, help="Output directory for .ipynb")
    args = parser.parse_args()
    build_all_notebooks(args.outline, args.explanations, args.out)


if __name__ == "__main__":
    main()
