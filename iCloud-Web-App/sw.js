const CACHE = 'unterrichtsplaner-icloud-v1';
const ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icon-192.png',
  '/icon-512.png',
  'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(cache => cache.addAll(ASSETS).catch(() => {}))
  );
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  // API calls + CloudKit Auth: immer Netzwerk, nie cachen
  if (e.request.url.includes('anthropic.com') ||
      e.request.url.includes('fonts.g') ||
      e.request.url.includes('apple-cloudkit.com') ||
      e.request.url.includes('icloud.com') ||
      e.request.url.includes('appleid.apple.com') ||
      e.request.url.includes('?code=') ||
      e.request.url.includes('?error=')) {
    e.respondWith(fetch(e.request).catch(() => new Response('', { status: 503 })));
    return;
  }
  // Rest: Cache-first
  e.respondWith(
    caches.match(e.request).then(cached => cached || fetch(e.request))
  );
});
