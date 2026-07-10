import 'dart:convert';

import 'package:island/plugins/icons/material_symbol_lookup.dart';
import 'package:island/plugins/icons/plugin_icon_font_registry.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:logging/logging.dart';

final _log = Logger('IconsApi');

/// Host API: Material Symbols + plugin-owned icon fonts.
///
/// Always available (no special permission). [register_font] only reads assets
/// inside the calling plugin’s folder (path-traversal safe).
///
/// JS surface:
/// - `icons.exists(name, font?)`
/// - `icons.lookup(name, style?, font?)`
/// - `icons.search(query, limit?, font?)`
/// - `icons.count(font?)`
/// - `icons.fonts()` — custom fonts registered by this plugin
/// - `icons.register_font(id, fontPath, glyphs)` — glyphs: object or JSON path
class IconsApi extends PluginApi {
  final PluginIconFontRegistry _registry = PluginIconFontRegistry.instance;

  @override
  Set<PluginPermission> get requiredPermissions => const {};

  @override
  String jsBindingsFor(Set<PluginPermission> granted) {
    // Always pass __plugin_id__ so custom fonts work outside of load
    // (commands / callbacks), not only while PluginManager.activePluginId is set.
    return '''
var icons = {};
function __pluginId() {
  return (typeof __plugin_id__ !== "undefined") ? __plugin_id__ : null;
}
icons.exists = function(name, font) {
  var r = sendMessage("api:icons:exists", JSON.stringify({name: name, font: font || null, pluginId: __pluginId()}));
  return r === true || r === "true";
};
icons.lookup = function(name, style, font) {
  var r = sendMessage("api:icons:lookup", JSON.stringify({name: name, style: style || null, font: font || null, pluginId: __pluginId()}));
  if (r == null || r === "" || r === "null") return null;
  try { return typeof r === "string" ? JSON.parse(r) : r; } catch (e) { return null; }
};
icons.search = function(query, limit, font) {
  var r = sendMessage("api:icons:search", JSON.stringify({query: query, limit: limit || 50, font: font || null, pluginId: __pluginId()}));
  if (r == null || r === "") return [];
  try { return typeof r === "string" ? JSON.parse(r) : r; } catch (e) { return []; }
};
icons.count = function(font) {
  var r = sendMessage("api:icons:count", JSON.stringify({font: font || null, pluginId: __pluginId()}));
  var n = typeof r === "string" ? parseInt(r, 10) : r;
  return isNaN(n) ? 0 : n;
};
icons.fonts = function() {
  var r = sendMessage("api:icons:fonts", JSON.stringify({pluginId: __pluginId()}));
  if (r == null || r === "") return [];
  try { return typeof r === "string" ? JSON.parse(r) : r; } catch (e) { return []; }
};
icons.register_font = function(id, fontPath, glyphs) {
  var r = sendMessage("api:icons:register_font", JSON.stringify({id: id, fontPath: fontPath, glyphs: glyphs, pluginId: __pluginId()}));
  if (r == null || r === "") return {ok: false, error: "no response"};
  try { return typeof r === "string" ? JSON.parse(r) : r; } catch (e) { return {ok: false, error: String(e)}; }
};
''';
  }

  String? _pluginId(Map<String, dynamic> data) =>
      data['pluginId']?.toString() ?? PluginManager.activePluginId;

  @override
  void register(JsRuntime runtime) {
    runtime.onMessage('api:icons:exists', (args) {
      try {
        final data = _decode(args);
        return _registry.exists(
          name: data['name']?.toString(),
          font: data['font']?.toString(),
          pluginId: _pluginId(data),
        );
      } catch (e) {
        _log.warning('icons.exists failed: $e');
        return false;
      }
    });

    runtime.onMessage('api:icons:lookup', (args) {
      try {
        final data = _decode(args);
        final result = _registry.lookup(
          name: data['name']?.toString(),
          style: data['style']?.toString(),
          font: data['font']?.toString(),
          pluginId: _pluginId(data),
        );
        return result == null ? 'null' : jsonEncode(result);
      } catch (e) {
        _log.warning('icons.lookup failed: $e');
        return 'null';
      }
    });

    runtime.onMessage('api:icons:search', (args) {
      try {
        final data = _decode(args);
        final query = data['query']?.toString() ?? '';
        final limit = (data['limit'] as num?)?.toInt() ?? 50;
        return jsonEncode(
          _registry.search(
            query: query,
            limit: limit.clamp(1, 200),
            font: data['font']?.toString(),
            pluginId: _pluginId(data),
          ),
        );
      } catch (e) {
        _log.warning('icons.search failed: $e');
        return '[]';
      }
    });

    runtime.onMessage('api:icons:count', (args) {
      try {
        final data = _decode(args);
        return _registry.count(
          font: data['font']?.toString(),
          pluginId: _pluginId(data),
        );
      } catch (e) {
        return MaterialSymbolLookup.count;
      }
    });

    runtime.onMessage('api:icons:fonts', (args) {
      try {
        final data = _decode(args);
        final pluginId = _pluginId(data);
        if (pluginId == null) return '[]';
        final list = _registry.fontsFor(pluginId).map((f) {
          return {
            'id': f.id,
            'fontFamily': f.fontFamily,
            'glyphCount': f.glyphs.length,
            'loaded': f.loaded,
            'error': f.loadError,
          };
        }).toList();
        return jsonEncode(list);
      } catch (e) {
        _log.warning('icons.fonts failed: $e');
        return '[]';
      }
    });

    runtime.onMessage('api:icons:register_font', (args) {
      try {
        final data = _decode(args);
        final pluginId = _pluginId(data);
        if (pluginId == null) {
          return jsonEncode({
            'ok': false,
            'error': 'No active plugin context',
          });
        }
        final id = data['id']?.toString() ?? '';
        final fontPath = data['fontPath']?.toString() ?? '';
        if (id.isEmpty || fontPath.isEmpty) {
          return jsonEncode({
            'ok': false,
            'error': 'id and fontPath are required',
          });
        }
        return jsonEncode(
          _registry.registerSync(
            pluginId: pluginId,
            id: id,
            fontPath: fontPath,
            glyphs: data['glyphs'],
          ),
        );
      } catch (e) {
        _log.warning('icons.register_font failed: $e');
        return jsonEncode({'ok': false, 'error': e.toString()});
      }
    });
  }

  @override
  void onPluginUnload(String pluginId) {
    _registry.clearPlugin(pluginId);
  }

  @override
  void reset() {
    _registry.clearAll();
  }

  Map<String, dynamic> _decode(dynamic args) {
    final data = args is String ? jsonDecode(args) : args;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }
}
