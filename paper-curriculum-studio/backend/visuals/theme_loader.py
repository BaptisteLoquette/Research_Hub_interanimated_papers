"""Load curriculum color themes from schemas/themes (Manim, matplotlib, three.js hints)."""
from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path


def _plugin_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _themes_dir() -> Path:
    return _plugin_root() / "schemas" / "themes"


@lru_cache(maxsize=1)
def load_theme_index() -> dict:
    return json.loads((_themes_dir() / "index.json").read_text(encoding="utf-8"))


def load_theme(theme_id: str) -> dict:
    index = load_theme_index()
    for entry in index["themes"]:
        if entry["id"] == theme_id:
            path = _themes_dir() / entry["file"]
            return json.loads(path.read_text(encoding="utf-8"))
    raise KeyError(f"Unknown theme_id: {theme_id}")


def manim_colors(theme_id: str) -> dict:
    """Returns manim subsection: background, text, accent, secondary, grid, highlight."""
    return dict(load_theme(theme_id)["manim"])


def matplotlib_rcparams(theme_id: str) -> dict:
    """Flat rcParams strings for matplotlib + series_colors list."""
    t = load_theme(theme_id)
    rc = dict(t["matplotlib"])
    rc["_series_colors"] = t.get("series_colors", [])
    return rc


def apply_matplotlib_theme(theme_id: str) -> None:
    """Call after importing matplotlib."""
    import matplotlib as mpl  # type: ignore

    rc = matplotlib_rcparams(theme_id)
    colors = rc.pop("_series_colors", [])
    mpl.rcParams.update({k: v for k, v in rc.items() if not k.startswith("_")})
    if colors:
        from cycler import cycler  # type: ignore

        mpl.rcParams["axes.prop_cycle"] = cycler(color=colors)
