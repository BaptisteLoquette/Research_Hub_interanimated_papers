/**
 * Theme types aligned with schemas/themes/*.json
 */

export type ThemeAppearance = "light" | "dark";

export type ThemeCssVars = Record<string, string>;

export type ThemeThreeFog = {
  color: string;
  near: number;
  far: number;
} | null;

export type ThemeThree = {
  background: string;
  fog: ThemeThreeFog;
  ambientIntensity: number;
  directionalColor: string;
  directionalIntensity: number;
  directionalPosition: [number, number, number];
  gridColor: string;
  accentHex: string;
};

export type ThemeManim = {
  background: string;
  text: string;
  accent: string;
  secondary: string;
  grid: string;
  highlight: string;
};

export type CurriculumTheme = {
  id: string;
  label: string;
  appearance: ThemeAppearance;
  description: string;
  css: ThemeCssVars;
  three: ThemeThree;
  manim: ThemeManim;
  matplotlib: Record<string, string>;
  series_colors: string[];
};

export type ThemeIndex = {
  version: number;
  default_theme_id: string;
  themes: { id: string; file: string }[];
};
