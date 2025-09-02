#!/usr/bin/env bash
set -euo pipefail

VIDEOS_DIR="assets/videos"
THUMBS_DIR="$VIDEOS_DIR/thumbs"
FINAL_SIZE="400x400"
FRAME_TIME="00:00:01.000" # Grab first second mark to avoid black frames

if [[ ! -d "$VIDEOS_DIR" ]]; then
  echo "No $VIDEOS_DIR directory; nothing to do." >&2
  exit 0
fi

mkdir -p "$THUMBS_DIR"

# Tooling checks
if command -v ffmpeg >/dev/null 2>&1; then
  :
else
  echo "Error: ffmpeg is required to extract thumbnails from videos." >&2
  exit 1
fi

# Optional ImageMagick for cropping to square
IM_TOOL=""
if command -v magick >/dev/null 2>&1; then
  IM_TOOL="magick"
elif command -v convert >/dev/null 2>&1; then
  IM_TOOL="convert"
fi

shopt -s nullglob
for src in "$VIDEOS_DIR"/*.{mp4,m4v,webm,mov,ogv}; do
  [[ -e "$src" ]] || continue
  base_name=$(basename "$src")
  name_no_ext=${base_name%.*}
  dest_jpg="$THUMBS_DIR/$name_no_ext.jpg"

  # Skip if up-to-date
  if [[ -f "$dest_jpg" && "$dest_jpg" -nt "$src" ]]; then
    continue
  fi

  tmp_jpg=$(mktemp -t vf.XXXXXX).jpg

  # Extract a frame at FRAME_TIME
  ffmpeg -y -ss "$FRAME_TIME" -i "$src" -vframes 1 -q:v 2 "$tmp_jpg" >/dev/null 2>&1 || {
    echo "ffmpeg frame extraction failed for $src" >&2
    rm -f "$tmp_jpg"
    continue
  }

  if [[ -n "$IM_TOOL" ]]; then
    # Center-crop to square then scale to FINAL_SIZE
    $IM_TOOL "$tmp_jpg" -auto-orient -thumbnail ${FINAL_SIZE}^ -gravity center -extent $FINAL_SIZE -quality 82 "$dest_jpg"
    rm -f "$tmp_jpg"
  else
    # Use ffmpeg scaling/crop as fallback
    ffmpeg -y -i "$tmp_jpg" -vf "scale='if(gt(a,1),-1,400)':'if(gt(a,1),400,-1)',crop=400:400" -q:v 3 "$dest_jpg" >/dev/null 2>&1 || cp "$tmp_jpg" "$dest_jpg"
    rm -f "$tmp_jpg"
  fi
  echo "Thumb: $base_name -> $(basename "$dest_jpg")"
done

# Refresh manifest if generator exists
if [[ -f scripts/generate-videos-manifest.js ]]; then
  if command -v node >/dev/null 2>&1; then
    node scripts/generate-videos-manifest.js || true
  else
    echo "Note: Node not found; skipping video manifest generation" >&2
  fi
fi

echo "Done."

