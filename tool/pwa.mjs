#!/usr/bin/env node
/**
 * Prepara y verifica la PWA después de `flutter build web`.
 *
 *   node tool/pwa.mjs build/web
 *
 * 1. Escribe en build/web/sw.js la lista de archivos a guardar en caché y
 *    una versión (hash del contenido) para que cada despliegue actualice
 *    la caché de los usuarios.
 * 2. Verifica los requisitos de una PWA instalable y con modo sin conexión.
 *    Si algo falla, termina con código 1 y el workflow de GitHub Actions
 *    se detiene antes de desplegar.
 */
import { createHash } from 'node:crypto';
import { existsSync, readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { join, relative, sep } from 'node:path';

const root = process.argv[2] ?? 'build/web';
const errors = [];
const ok = [];

function check(condition, message) {
  (condition ? ok : errors).push(message);
}

function listFiles(dir) {
  return readdirSync(dir).flatMap((name) => {
    const full = join(dir, name);
    return statSync(full).isDirectory() ? listFiles(full) : [full];
  });
}

if (!existsSync(root)) {
  console.error(`No existe ${root}. Ejecuta primero: flutter build web`);
  process.exit(1);
}

// ---------------------------------------------------------------------------
// 1. Lista de precaché + versión
// ---------------------------------------------------------------------------
const skip = new Set(['sw.js', '.last_build_id', 'version.json']);
const files = listFiles(root)
  .map((file) => relative(root, file).split(sep).join('/'))
  .filter((file) => !skip.has(file) && !file.endsWith('.map') && !file.startsWith('.'))
  .sort();

const hash = createHash('sha256');
for (const file of files) {
  hash.update(file);
  hash.update(readFileSync(join(root, file)));
}
const version = hash.digest('hex').slice(0, 12);

const swPath = join(root, 'sw.js');
check(existsSync(swPath), 'Existe el service worker sw.js');
if (existsSync(swPath)) {
  let sw = readFileSync(swPath, 'utf8');
  const before = sw;
  sw = sw.replace(/const VERSION = '[^']*';/, `const VERSION = '${version}';`);
  sw = sw.replace(/const PRECACHE = \[[^\]]*\];/, `const PRECACHE = ${JSON.stringify(files)};`);
  check(sw !== before, 'Se escribió la lista de precaché en sw.js');
  writeFileSync(swPath, sw);
  check(/addEventListener\(['"]fetch['"]/.test(sw), 'sw.js responde peticiones (evento fetch)');
  check(/addEventListener\(['"]install['"]/.test(sw), 'sw.js guarda archivos al instalarse');
}

// ---------------------------------------------------------------------------
// 2. Verificación de PWA
// ---------------------------------------------------------------------------
const manifestPath = join(root, 'manifest.json');
check(existsSync(manifestPath), 'Existe manifest.json');
if (existsSync(manifestPath)) {
  let manifest = {};
  try {
    manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
    ok.push('manifest.json es JSON válido');
  } catch (e) {
    errors.push(`manifest.json no es JSON válido: ${e.message}`);
  }
  check(Boolean(manifest.name), 'manifest: tiene "name"');
  check(Boolean(manifest.short_name), 'manifest: tiene "short_name"');
  check(Boolean(manifest.start_url), 'manifest: tiene "start_url"');
  check(
    ['standalone', 'fullscreen', 'minimal-ui'].includes(manifest.display),
    'manifest: "display" es standalone, fullscreen o minimal-ui',
  );
  check(Boolean(manifest.theme_color), 'manifest: tiene "theme_color"');
  check(Boolean(manifest.background_color), 'manifest: tiene "background_color"');
  const icons = Array.isArray(manifest.icons) ? manifest.icons : [];
  for (const size of ['192x192', '512x512']) {
    const icon = icons.find((i) => (i.sizes ?? '').split(' ').includes(size));
    check(Boolean(icon), `manifest: tiene ícono de ${size}`);
    if (icon) check(existsSync(join(root, icon.src)), `El ícono ${icon.src} existe`);
  }
  check(
    icons.some((i) => (i.purpose ?? '').includes('maskable')),
    'manifest: tiene ícono "maskable" (Android)',
  );
}

const indexPath = join(root, 'index.html');
check(existsSync(indexPath), 'Existe index.html');
if (existsSync(indexPath)) {
  const html = readFileSync(indexPath, 'utf8');
  check(/<link[^>]+rel=["']manifest["']/.test(html), 'index.html enlaza el manifest');
  check(/serviceWorker\.register\(\s*['"]sw\.js['"]/.test(html), 'index.html registra sw.js');
  check(/<meta[^>]+name=["']theme-color["']/.test(html), 'index.html tiene theme-color');
  check(/<meta[^>]+name=["']viewport["']/.test(html), 'index.html tiene viewport (responsive)');
  check(!html.includes('$FLUTTER_BASE_HREF'), 'index.html tiene el base href definitivo');
}

for (const required of ['main.dart.js', 'flutter_bootstrap.js']) {
  check(files.includes(required), `El build incluye ${required} (en la precaché)`);
}
check(
  files.some((file) => file.startsWith('canvaskit/')),
  'CanvasKit se sirve desde la app (funciona sin conexión)',
);
check(
  files.some((file) => file.startsWith('assets/')),
  'Los assets (fuentes, íconos) están en la precaché',
);

for (const message of ok) console.log(`  ✓ ${message}`);
for (const message of errors) console.log(`  ✗ ${message}`);
console.log(`\nPrecaché: ${files.length} archivos · versión ${version}`);

if (errors.length > 0) {
  console.error(`\nLa app NO cumple con los requisitos de PWA (${errors.length} error/es).`);
  process.exit(1);
}
console.log('\nLa app cumple con los requisitos de PWA (instalable y sin conexión).');
