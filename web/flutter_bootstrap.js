{{flutter_js}}
{{flutter_build_config}}

// Arranque de Flutter sin su service worker por defecto: la app usa su
// propio service worker (sw.js). CanvasKit se carga desde la propia
// página y no desde un CDN, para que todo funcione sin conexión.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
});
