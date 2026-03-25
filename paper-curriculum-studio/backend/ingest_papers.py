#!/usr/bin/env python3
"""
Paper ingestion stub: creates artifact templates for the curriculum pipeline.
Extend with PDF parsing (pypdf, pymupdf, etc.) and structured extraction.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from datetime import datetime, timezone


def minimal_outline(pdf_path: str | None) -> dict:
    return {
        "source": pdf_path or "(no file — manual / agent-filled)",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "title": "",
        "abstract": "",
        "sections": {
            "introduction": [],
            "related_work": [],
            "methods": [],
            "experiments": [],
            "limitations": [],
            "appendix": [],
        },
        "equations": [],
        "definitions": [],
        "algorithms": [],
        "figures": [],
        "warnings": [],
    }


def minimal_graph() -> dict:
    return {
        "nodes": [],
        "edges": [],
    }


def main() -> None:
    p = argparse.ArgumentParser(description="Ingest papers → paper_outline.json + concept_graph.json")
    p.add_argument("--session", required=True, help="Session id (folder name under artifacts/)")
    p.add_argument("--pdf", default=None, help="Optional path to PDF")
    p.add_argument(
        "--artifacts-root",
        default=None,
        help="Root artifacts directory (default: backend/artifacts next to this script)",
    )
    args = p.parse_args()

    here = Path(__file__).resolve().parent
    root = Path(args.artifacts_root) if args.artifacts_root else here / "artifacts"
    out_dir = root / args.session
    out_dir.mkdir(parents=True, exist_ok=True)

    outline_path = out_dir / "paper_outline.json"
    graph_path = out_dir / "concept_graph.json"

    outline_path.write_text(json.dumps(minimal_outline(args.pdf), indent=2), encoding="utf-8")
    graph_path.write_text(json.dumps(minimal_graph(), indent=2), encoding="utf-8")

    print(f"Wrote {outline_path}")
    print(f"Wrote {graph_path}")


if __name__ == "__main__":
    main()
