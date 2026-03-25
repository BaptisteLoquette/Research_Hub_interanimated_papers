import type { CurriculumTheme } from "./types";

/** Map JSON theme.three to R3F scene defaults (ambient + directional + background). */
export function sceneLightingFromTheme(t: CurriculumTheme) {
  return {
    background: t.three.background,
    fog: t.three.fog,
    ambient: { intensity: t.three.ambientIntensity },
    directional: {
      color: t.three.directionalColor,
      intensity: t.three.directionalIntensity,
      position: t.three.directionalPosition as [number, number, number],
    },
    gridColor: t.three.gridColor,
    accentHex: t.three.accentHex,
  };
}
