#!/usr/bin/env bash
set -euo pipefail

PHOTOS_DIR="assets/photos"
THUMBS_DIR="$PHOTOS_DIR/thumbs"
SIZE="400x400"

if [[ ! -d "$PHOTOS_DIR" ]]; then
  echo "Error: $PHOTOS_DIR not found" >&2
  exit 1
fi

mkdir -p "$THUMBS_DIR"

# Choose tool: prefer sips on macOS, fallback to ImageMagick
if command -v sips >/dev/null 2>&1; then
  TOOL="sips"
elif command -v magick >/dev/null 2>&1; then
  TOOL="magick"
elif command -v convert >/dev/null 2>&1; then
  TOOL="convert"
else
  echo "Error: need 'sips' (macOS) or ImageMagick ('magick'/'convert') installed" >&2
  exit 1
fi

process_imagemagick() {
  local src="$1" dest="$2"
  if command -v magick >/dev/null 2>&1; then
    magick convert "$src" -auto-orient -thumbnail ${SIZE}^ -gravity center -extent $SIZE -quality 82 "$dest"
  else
    convert "$src" -auto-orient -thumbnail ${SIZE}^ -gravity center -extent $SIZE -quality 82 "$dest"
  fi
}

process_sips() {
  local src="$1" dest="$2"
  # Query original dimensions
  local info width height
  info=$(sips -g pixelWidth -g pixelHeight "$src" 2>/dev/null)
  width=$(echo "$info" | awk '/pixelWidth/ {print $2}')
  height=$(echo "$info" | awk '/pixelHeight/ {print $2}')
  # Work on a temp file to avoid mutating originals
  local tmp
  tmp=$(mktemp -t thumb.XXXXXX)
  cp "$src" "$tmp"
  # Resize so the smaller dimension is 400, then center-crop to 400x400
  if [[ -n "$width" && -n "$height" && "$width" -gt "$height" ]]; then
    sips --resampleHeight 400 "$tmp" >/dev/null
  else
    sips --resampleWidth 400 "$tmp" >/dev/null
  fi
  sips --cropToHeightWidth 400 400 "$tmp" >/dev/null
  mv "$tmp" "$dest"
}

echo "Generating thumbnails to $THUMBS_DIR using $TOOL..."

# Find images in PHOTOS_DIR (excluding thumbs and manifest)
while IFS= read -r -d '' src; do
  base_name=$(basename "$src")
  name_no_ext=${base_name%.*}
  ext=${base_name##*.}

  # Skip manifest and hidden files
  [[ "$base_name" == "manifest.json" ]] && continue
  [[ "$base_name" == .* ]] && continue

  dest="$THUMBS_DIR/$name_no_ext.$ext"

  # SVG: just copy (no rasterizer assumed)
  if [[ "$ext" =~ ^([sS][vV][gG])$ ]]; then
    if [[ ! -f "$dest" || "$dest" -ot "$src" ]]; then
      cp "$src" "$dest"
      echo "Copied SVG thumb: $base_name"
    fi
    continue
  fi

  # Skip if up-to-date
  if [[ -f "$dest" && "$dest" -nt "$src" ]]; then
    continue
  fi

  case "$TOOL" in
    sips)
      process_sips "$src" "$dest"
      ;;
    magick|convert)
      process_imagemagick "$src" "$dest"
      ;;
  esac
  echo "Thumb: $base_name -> $(basename "$dest")"
done < <(find "$PHOTOS_DIR" -maxdepth 1 -type f -print0)

# Refresh manifest if the generator exists
if [[ -f scripts/generate-photos-manifest.js ]]; then
  if command -v node >/dev/null 2>&1; then
    node scripts/generate-photos-manifest.js || true
  else
    echo "Note: Node not found; skipping manifest generation" >&2
  fi
fi

echo "Done."

