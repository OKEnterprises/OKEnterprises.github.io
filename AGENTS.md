# Repository Guidelines

## Project Structure & Module Organization
- Root-level static site served by GitHub Pages.
- Key files: `index.html` (home), `photos.html` (placeholder), `style.css` (global CSS), `Cenotaph-Titling.otf` (font), `CNAME` (custom domain).
- Add new pages as `*.html` at repo root and link them from the sidebar menu in `index.html`.

## Build, Test, and Development Commands
- No build step or package tooling required. Site deploys from `main` as-is.
- Local preview: `python3 -m http.server 4000` then visit `http://localhost:4000`.
- Alternative (Node): `npx serve .` if you prefer a simple server.
- Note: `package-lock.json` is present but there is no `package.json`; Node tooling is not used for builds.

## Coding Style & Naming Conventions
- Indentation: 4 spaces in HTML/CSS to match existing files.
- HTML: Use semantic tags where possible; keep navigation in the `.menu` inside the `.sidebar`.
- CSS: Lowercase, hyphenated class names (e.g., `.sidebar`, `.menu`). Extend `style.css`; co-locate font-face and global rules there.
- Assets: Keep font files at root (consistent with current setup). If adding images, prefer a new `assets/` folder and reference with relative paths (e.g., `assets/photos/cat.jpg`).

## Testing Guidelines
- No automated tests. Verify pages manually in modern browsers.
- Check layout at common widths (mobile, tablet, desktop). Use browser dev tools or Lighthouse for quick accessibility/performance checks.
- Ensure all new links are reachable and relative paths resolve locally and on GitHub Pages.

## Commit & Pull Request Guidelines
- Commits: Short, imperative summaries in present tense (e.g., "Add photos page", "Refine sidebar spacing"). Scope in body if needed.
- PRs: Include a brief description of changes, before/after screenshots for visual tweaks, and link any related issues.
- Keep changes focused; update navigation links when adding or renaming pages.

## Security & Configuration Tips
- Do not remove or rename `CNAME`; it configures the custom domain.
- Host fonts/assets locally (current pattern) to avoid third-party dependency drift.

## Photos: Thumbnails & Manifest
- Generate thumbnails and manifest before committing:
  - `bash scripts/generate-thumbs.sh` (uses `sips` on macOS or ImageMagick)
  - This writes `assets/photos/thumbs/` and updates `assets/photos/manifest.json`.
- Add full images to `assets/photos/`; thumbs are produced automatically with center-cropped 400x400 squares.
