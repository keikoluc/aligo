// Before this deploy, the Flutter web app lived at "/" and registered a
// service worker scoped to "/" for offline support (see the old
// web/index.html's flutter_bootstrap.js). The app has since moved to
// "/app/" (its own, separately-scoped service worker) and "/" is now
// this static landing page — but browsers that visited before this
// change still have that old "/"-scoped service worker installed,
// which keeps intercepting requests here and serving a stale cached
// copy of the old app shell (broken JS/asset paths, since they no
// longer exist at these URLs).
//
// The browser periodically re-fetches whatever URL a service worker was
// registered from to check for updates; this file replaces that old
// script so the update check finds different bytes, installs this
// version, and immediately unregisters itself and clears every cache it
// owns — self-destructing so plain requests to "/" reach the server
// (and this landing page) normally again.
self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(keys.map((key) => caches.delete(key)));
      await self.registration.unregister();
      const clients = await self.clients.matchAll({ type: 'window' });
      clients.forEach((client) => client.navigate(client.url));
    })()
  );
});
