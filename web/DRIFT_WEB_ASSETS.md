# Drift web assets

The unified `AppDatabase` uses Drift on the web. Before publishing the web
app, place these version-matched files in this directory:

- `sqlite3.wasm` and `drift_worker.dart.js` from the Drift release matching
  the `drift` version in `pubspec.lock`.

For this project, the pinned Drift runtime is currently `2.34.2`; its release
assets have already been added here. When upgrading Drift, replace both files
with the two assets from the matching Drift GitHub release. The hosting
configuration must serve the WASM file as `application/wasm`; `web/_headers`
covers this for hosts supporting Cloudflare Pages-style headers.

Drift uses OPFS when browser security features permit it and falls back to
IndexedDB otherwise. Do not add COOP/COEP globally without checking the app's
OAuth and popup integrations first.
