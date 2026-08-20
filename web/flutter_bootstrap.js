{{flutter_js}}
{{flutter_build_config}}

// Match the previous behaviour: force CanvasKit so canvasKitBaseUrl is honored.
// NOTE: replace canvasKitBaseUrl with your real China-accessible CanvasKit mirror.
// There is no official gstatic.cn endpoint; use a self-hosted/CDN copy of the
// canvaskit files built for this Flutter engine version (or serve them yourself).
const useCanvasKit = true;

_flutter.loader.load({
  config: {
    renderer: useCanvasKit ? "canvaskit" : "skwasm",
    canvasKitBaseUrl: "https://your-mirror-domain.com",
  },
});
