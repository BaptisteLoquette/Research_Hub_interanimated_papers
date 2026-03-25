# Web curriculum (Next.js + react-three-fiber)

## Intended stack

- **Next.js** + React + Tailwind (or minimal CSS).
- `@react-three/fiber`, `@react-three/drei` for interactive 3D lesson scenes.
- KaTeX or MathJax for formulas.

## Themes (CSS + Three.js)

- **Source of truth**: `../schemas/themes/*.json` (8 presets: Paper Light/Dark, Graphite, Mist, Ink, Sage, Harbor, Clay).
- **Generated CSS**: import `styles/curriculum-themes.css`, then set `document.documentElement.dataset.curTheme = '<id>'` (see `themes/useCurriculumTheme.ts`). Regenerate after editing JSON:

  ```bash
  python3 ../backend/generate_theme_css.py
  ```

- **R3F**: use `sceneLightingFromTheme()` from `themes/threeFromTheme.ts` after loading the same JSON (copy into `public/themes/` or import in Next with a JSON import).
- **Per-lesson theme**: each entry in `visual_specs.json` may include `theme_id`; default is `schemas/themes/index.json` → `default_theme_id`.

## Layout contract

Match **ui-ux-learning** / **experience-design**:

- Left: TOC / breadcrumbs.
- Center: primary `<Canvas>` or diagram.
- Right: collapsible formula breakdown / code / citations.

## Visual presets

See `../schemas/visual_spec_presets.json` for reusable `preset` ids (vector fields, graphs, ReAct loop, RAG stack, Bloch sphere, etc.) and suggested `default_theme_id` per preset.

## Bootstrap (in a project repo)

```bash
npx create-next-app@latest web --ts --tailwind --eslint --app
cd web
npm install @react-three/fiber @react-three/drei three
npm run dev
```

Copy `components/LessonScene.example.tsx` into your app and wire routes from `curriculum_outline.json`.
