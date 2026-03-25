/**
 * Browser: set <html data-cur-theme="paper-sf-light"> and import ../styles/curriculum-themes.css
 */
export function setCurriculumTheme(themeId: string, el: HTMLElement | null = null) {
  const root = el ?? (typeof document !== "undefined" ? document.documentElement : null);
  if (!root) return;
  root.dataset.curTheme = themeId;
}

export function listThemeIds(): string[] {
  return [
    "paper-sf-light",
    "paper-sf-dark",
    "graphite-dark",
    "mist-light",
    "ink-dark",
    "sage-light",
    "harbor-dark",
    "clay-light",
  ];
}
