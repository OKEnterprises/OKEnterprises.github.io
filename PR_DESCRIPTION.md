**Title**
Add static photo gallery, manifest loader, and auto thumbnail generation

**Summary**
- Adds a responsive photo grid with a lightbox.
- Auto-builds thumbnails and a manifest from `assets/photos/`.
- Documents contributor workflow in AGENTS.md, including feature-branch workflow and frequent commits.

**Changes**
- `photos.html`: Gallery markup, lightbox, loads `assets/photos/manifest.json` with a JS fallback.
- `style.css`: Gallery and lightbox styles.
- `scripts/generate-thumbs.sh`: Creates 400x400 center-cropped thumbnails via `sips` or ImageMagick.
- `scripts/generate-photos-manifest.js`: Scans photos/thumbs and writes `assets/photos/manifest.json`.
- `assets/photos/*` and `assets/photos/thumbs/*`: Placeholder images.
- `AGENTS.md`: Repository guidelines and photos workflow; added requirement to create feature branches and commit regularly.

**How To Test**
- Local server: `python3 -m http.server 4000` then open `http://localhost:4000/photos.html`.
- Verify:
  - Grid renders with 6 placeholders.
  - Clicking opens lightbox; click overlay or press Escape to close.
  - Responsive layout at mobile/tablet/desktop widths.

**Usage**
- Add full images to `assets/photos/`.
- Generate thumbnails and manifest:
  - `bash scripts/generate-thumbs.sh`
  - (This also runs the manifest generator if Node is available.)
- Commit `assets/photos/thumbs/` and `assets/photos/manifest.json`.

**Screenshots**
- Before: N/A (empty photos.html)
- After: [Add desktop and mobile screenshots]

**Accessibility**
- Lightbox uses `role="dialog"`, `aria-hidden`, and Escape handling.
- `alt` derived from filenames; editable in manifest if needed.

**Risks / Notes**
- No impact to `index.html` nav (photos link already exists).
- `CNAME` unchanged.
- If neither `sips` nor ImageMagick is installed, thumbnails won’t be generated (script errors with guidance).

**Checklist**
- [ ] Screenshots attached (desktop + mobile)
- [ ] Thumbnails generated and manifest updated
- [ ] Links verified (no 404s)
- [ ] Cross-browser spot check (Safari/Chrome/Firefox)
- [ ] Accessibility quick pass (keyboard nav, alt text)
- [ ] Docs reflect branching/commit workflow

