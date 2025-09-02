#!/usr/bin/env node
/*
Generates assets/videos/manifest.json from files in assets/videos and assets/videos/thumbs.
*/
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const videosDir = path.join(root, 'assets', 'videos');
const thumbsDir = path.join(videosDir, 'thumbs');
const manifestPath = path.join(videosDir, 'manifest.json');

const videoExts = new Set(['.mp4', '.webm', '.mov', '.m4v', '.ogv']);
const imageExts = new Set(['.jpg', '.jpeg', '.png', '.webp']);

function isFile(p){ try { return fs.statSync(p).isFile(); } catch { return false; } }
function titleCase(s){ return s.replace(/[-_]+/g,' ').replace(/\s+/g,' ').trim().replace(/\b\w/g, c=>c.toUpperCase()); }

function findThumb(base, thumbs){
  const re = new RegExp('^' + base.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '\\.', 'i');
  const t = thumbs.find(name => re.test(name));
  return t ? 'assets/videos/thumbs/' + t : null;
}

function mimeFor(src){
  const ext = path.extname(src).toLowerCase();
  switch (ext) {
    case '.mp4':
    case '.m4v':
      return 'video/mp4';
    case '.webm':
      return 'video/webm';
    case '.ogv':
      return 'video/ogg';
    case '.mov':
      return 'video/quicktime';
    default:
      return 'video/mp4';
  }
}

function main(){
  if (!fs.existsSync(videosDir)) {
    console.error('Missing directory:', videosDir);
    process.exit(0);
  }

  const files = fs.readdirSync(videosDir)
    .filter(name => name !== 'thumbs' && name !== 'manifest.json' && !name.startsWith('.'))
    .filter(name => isFile(path.join(videosDir, name)) && videoExts.has(path.extname(name).toLowerCase()));

  const thumbs = fs.existsSync(thumbsDir)
    ? fs.readdirSync(thumbsDir).filter(name => isFile(path.join(thumbsDir, name)) && imageExts.has(path.extname(name).toLowerCase()))
    : [];

  const entries = files.map(filename => {
    const ext = path.extname(filename);
    const base = path.basename(filename, ext);
    const src = `assets/videos/${filename}`;
    const thumb = findThumb(base, thumbs) || null;
    const alt = titleCase(base);
    const type = mimeFor(src);
    return { src, thumb, alt, type };
  }).sort((a,b) => a.src.localeCompare(b.src));

  fs.writeFileSync(manifestPath, JSON.stringify(entries, null, 2) + '\n');
  console.log('Wrote', manifestPath, `(${entries.length} items)`);
}

main();

