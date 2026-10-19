/*
 * Service worker de 15-Puzzle Flutter.
 *
 * - Al instalarse guarda en caché todos los archivos de la app (la lista la
 *   escribe tool/pwa.mjs después de `flutter build web`).
 * - Navegación: primero la red y, sin conexión, la copia guardada.
 * - Resto de archivos: primero la caché y, si no está, la red (y se guarda).
 *
 * Así el juego se puede instalar como PWA y abrir sin internet.
 */

// tool/pwa.mjs reemplaza estas dos líneas al compilar.
const VERSION = 'dev';
const PRECACHE = [];

const CACHE = `puzzle15-${VERSION}`;
const CORE = ['./', 'index.html', 'manifest.json', 'flutter_bootstrap.js'];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE)
      .then((cache) => cache.addAll([...new Set([...CORE, ...PRECACHE])]))
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys
          .filter((key) => key.startsWith('puzzle15-') && key !== CACHE)
          .map((key) => caches.delete(key)),
      ))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  // Páginas: red primero, caché como respaldo sin conexión.
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put('index.html', copy));
          return response;
        })
        .catch(() => caches.match('index.html').then((r) => r || caches.match('./'))),
    );
    return;
  }

  // Archivos: caché primero; si falta, se descarga y se guarda.
  event.respondWith(
    caches.match(request).then((cached) => {
      if (cached) return cached;
      return fetch(request).then((response) => {
        if (response && (response.ok || response.type === 'opaque')) {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put(request, copy));
        }
        return response;
      });
    }),
  );
});
