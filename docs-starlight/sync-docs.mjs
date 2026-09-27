// Mirrors the repo's plain .md files into src/content/docs/ with a
// `title:` frontmatter injected (Starlight requires one per page).
// This project has no frontmatter convention of its own, so this is the
// glue needed to preview the same content under Starlight.
import fs from 'node:fs';
import path from 'node:path';

const REPO_DIR = '/repo';
const OUT_DIR = new URL('./src/content/docs/', import.meta.url).pathname;
const SKIP_DIRS = new Set(['.git', '.idea', '.claude', 'docs-starlight', 'node_modules']);

function mapTargetPath(relPath) {
  if (relPath === 'DASHBOARD.md') return 'index.md';
  if (relPath === 'README.md') return 'readme.md';
  if (relPath === 'ROADMAP.md') return 'roadmap.md';
  if (relPath === 'PITFALLS.md') return 'pitfalls.md';

  const parts = relPath.split(path.sep);
  if (parts.length === 2 && parts[1] === 'README.md') {
    return `${parts[0]}/index.md`;
  }
  if (parts.length === 3 && parts[2] === 'README.md') {
    return `${parts[0]}/${parts[1]}.md`;
  }
  return relPath;
}

function deriveTitle(content, fallback) {
  const match = content.match(/^#\s+(.+)$/m);
  return (match ? match[1] : fallback).replace(/"/g, '\\"');
}

function walk(dir, base = '') {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (SKIP_DIRS.has(entry.name)) continue;
    const abs = path.join(dir, entry.name);
    const rel = path.join(base, entry.name);
    if (entry.isDirectory()) {
      walk(abs, rel);
    } else if (entry.name.endsWith('.md')) {
      const content = fs.readFileSync(abs, 'utf8');
      const title = deriveTitle(content, path.basename(entry.name, '.md'));
      const target = path.join(OUT_DIR, mapTargetPath(rel));
      fs.mkdirSync(path.dirname(target), { recursive: true });
      fs.writeFileSync(target, `---\ntitle: "${title}"\n---\n\n${content}`);
    }
  }
}

fs.rmSync(OUT_DIR, { recursive: true, force: true });
fs.mkdirSync(OUT_DIR, { recursive: true });
walk(REPO_DIR);
console.log('[sync-docs] synced repo markdown into src/content/docs/');
