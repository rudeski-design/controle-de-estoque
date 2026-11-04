const V = "estoque-v7"; // mude para v2, v3… a cada atualização do app
const SHELL = ["/", "/index.html", "/config.js", "/manifest.webmanifest", "/icons/icon-192.png", "/icons/icon-512.png"];
self.addEventListener("install", e => {
  e.waitUntil(caches.open(V).then(c => c.addAll(SHELL)));
  self.skipWaiting();
});
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(k => Promise.all(k.filter(x => x !== V).map(x => caches.delete(x)))));
  self.clients.claim();
});
self.addEventListener("fetch", e => {
  if (e.request.method !== "GET") return;
  const u = new URL(e.request.url);
  const ok = u.origin === location.origin || u.hostname === "cdn.jsdelivr.net" ||
             u.hostname === "fonts.googleapis.com" || u.hostname === "fonts.gstatic.com";
  if (!ok) return; // a API do Supabase nunca passa pelo cache
  e.respondWith(
    fetch(e.request).then(r => { const c = r.clone(); caches.open(V).then(x => x.put(e.request, c)); return r; })
      .catch(() => caches.match(e.request).then(m => m || caches.match("/index.html")))
  );
});
