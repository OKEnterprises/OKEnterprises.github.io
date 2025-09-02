#!/usr/bin/env node
/*
Generates assets/photos/manifest.json from files in assets/photos and assets/photos/thumbs.
Usage: node scripts/generate-photos-manifest.js
*/
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const photosDir = path.join(root, 'assets', 'photos');
const thumbsDir = path.join(photosDir, 'thumbs');
const manifestPath = path.join(photosDir, 'manifest.json');

function isFile(p) {
  try { return fs.statSync(p).isFile(); } catch { return false; }
}

function titleCase(s) {
  return s.replace(/[-_]+/g, ' ').replace(/\s+/g, ' ').trim()
    .replace(/\b\w/g, c => c.toUpperCase());
}

function main(){
  if (!fs.existsSync(photosDir)) {
    console.error('Missing directory:', photosDir);
    process.exit(1);
  }

  const all = fs.readdirSync(photosDir)
    .filter(name => name !== 'thumbs')
    .filter(name => isFile(path.join(photosDir, name)));

  const thumbs = fs.existsSync(thumbsDir) ? fs.readdirSync(thumbsDir).filter(name => isFile(path.join(thumbsDir, name))) : [];

  function findThumb(base) {
    // Prefer exact same basename (any extension)
    const re = new RegExp('^' + base.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '\\.', 'i');
    const match = thumbs.find(t => re.test(t));
    return match ? 'assets/photos/thumbs/' + match : null;
  }

  const entries = all.map(filename => {
    const ext = path.extname(filename);
    const base = path.basename(filename, ext);
    const src = `assets/photos/${filename}`;
    const thumb = findThumb(base) || src;
    const alt = titleCase(base);
    return { src, thumb, alt };
  }).sort((a,b) => a.src.localeCompare(b.src));

  fs.writeFileSync(manifestPath, JSON.stringify(entries, null, 2) + '\n');
  console.log('Wrote', manifestPath, `(${entries.length} items)`);
}

main();

