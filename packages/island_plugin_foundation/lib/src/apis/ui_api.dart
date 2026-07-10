import 'dart:convert';

import 'package:island_plugin_foundation/src/apis/plugin_api.dart';
import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:island_plugin_foundation/src/plugin_manager.dart';
import 'package:logging/logging.dart';

final _log = Logger('UiApi');

/// A UI descriptor returned by a plugin.
///
/// Plugins return structured data (JSON-like maps) that the host renders as widgets.
class PluginUiDescriptor {
  final String type;
  final Map<String, dynamic> data;

  const PluginUiDescriptor({required this.type, required this.data});
}

/// Exposes UI building functions to JavaScript plugins.
///
/// Descriptor builders only — host apps render them (and may register extra UI
/// channels such as dashboard items as separate [PluginApi]s).
class UiApi extends PluginApi {
  @override
  Set<PluginPermission> get requiredPermissions => {PluginPermission.uiRender};

  @override
  String jsBindingsFor(Set<PluginPermission> granted) {
    if (!granted.contains(PluginPermission.uiRender)) return '';
    return '''
var ui = ui || {};
ui.card = function(title, body, actions) {
  var result = sendMessage("api:ui:card", JSON.stringify({title: title, body: body, actions: actions || []}));
  return result;
};
ui.list_items = function(items) {
  return sendMessage("api:ui:list_items", JSON.stringify({items: items}));
};
ui.button = function(label, callback) {
  return sendMessage("api:ui:button", JSON.stringify({label: label, callback: callback || null}));
};
ui.text = function(content) {
  return sendMessage("api:ui:text", JSON.stringify({content: content}));
};
ui.section = function(title, children) {
  return sendMessage("api:ui:section", JSON.stringify({title: title, children: children || []}));
};
ui.divider = function() {
  return sendMessage("api:ui:divider", "{}");
};
ui.page = function(title, child) {
  return sendMessage("api:ui:page", JSON.stringify({title: title, child: child}));
};
ui.row = function(children) {
  return sendMessage("api:ui:row", JSON.stringify({children: children || []}));
};
ui.column = function(children) {
  return sendMessage("api:ui:column", JSON.stringify({children: children || []}));
};
ui.spacing = function(size) {
  return sendMessage("api:ui:spacing", JSON.stringify({size: size}));
};
ui.icon = function(name, size, style, font) {
  return sendMessage("api:ui:icon", JSON.stringify({
    name: name,
    size: size,
    style: style || null,
    font: font || null,
    pluginId: (typeof __plugin_id__ !== "undefined") ? __plugin_id__ : null
  }));
};
ui.link = function(label, url) {
  return sendMessage("api:ui:link", JSON.stringify({label: label, url: url}));
};
ui.input = function(label, hint, callback) {
  return sendMessage("api:ui:input", JSON.stringify({label: label, hint: hint, callback: callback}));
};
ui.cloud_file = function(id, fit) {
  return sendMessage("api:ui:cloud_file", JSON.stringify({id: id, fit: fit}));
};
ui.image = function(url, fit) {
  return sendMessage("api:ui:image", JSON.stringify({url: url, fit: fit}));
};
ui.audio = function(url, filename, autoplay) {
  return sendMessage("api:ui:audio", JSON.stringify({url: url, filename: filename, autoplay: autoplay}));
};
ui.video = function(url, aspectRatio, autoplay) {
  return sendMessage("api:ui:video", JSON.stringify({url: url, aspectRatio: aspectRatio, autoplay: autoplay}));
};
ui.plugin_asset = function(path, kind, fit) {
  return sendMessage("api:ui:plugin_asset", JSON.stringify({path: path, kind: kind, fit: fit}));
};
''';
  }

  @override
  void register(JsRuntime runtime) {
    runtime.onMessage('api:ui:card', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final title = data['title']?.toString() ?? '';
        final body = data['body']?.toString() ?? '';
        final actions = data['actions'];

        final result = <String, dynamic>{
          'type': 'card',
          'title': title,
          'body': body,
        };
        if (actions is List && actions.isNotEmpty) {
          result['actions'] = actions;
        }

        return jsonEncode(result);
      } catch (e) {
        _log.warning('ui.card error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:list_items', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final items = data['items'];

        final result = <String, dynamic>{
          'type': 'list',
          'items': items is List ? items : [items?.toString()],
        };

        return jsonEncode(result);
      } catch (e) {
        _log.warning('ui.list_items error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:button', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final label = data['label']?.toString() ?? '';
        final callback = data['callback']?.toString();

        final result = <String, dynamic>{'type': 'button', 'label': label};
        if (callback != null) {
          result['callback'] = callback;
        }

        return jsonEncode(result);
      } catch (e) {
        _log.warning('ui.button error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:text', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final content = data['content']?.toString() ?? '';

        return jsonEncode({'type': 'text', 'content': content});
      } catch (e) {
        _log.warning('ui.text error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:section', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final title = data['title']?.toString() ?? '';
        final children = data['children'];

        final result = <String, dynamic>{
          'type': 'section',
          'title': title,
          'children': children is List ? children : [],
        };

        return jsonEncode(result);
      } catch (e) {
        _log.warning('ui.section error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:divider', (args) {
      return jsonEncode({'type': 'divider'});
    });

    runtime.onMessage('api:ui:page', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        return jsonEncode({
          'type': 'page',
          'title': data['title']?.toString() ?? '',
          'child': data['child'],
        });
      } catch (e) {
        _log.warning('ui.page error: $e');
        return '{}';
      }
    });

    for (final type in const ['row', 'column']) {
      runtime.onMessage('api:ui:$type', (args) {
        try {
          final data = args is String ? jsonDecode(args) : args;
          return jsonEncode({
            'type': type,
            'children': data['children'] is List ? data['children'] : [],
          });
        } catch (e) {
          _log.warning('ui.$type error: $e');
          return '{}';
        }
      });
    }

    runtime.onMessage('api:ui:spacing', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        return jsonEncode({
          'type': 'spacing',
          'size': (data['size'] as num?)?.toDouble() ?? 8,
        });
      } catch (e) {
        _log.warning('ui.spacing error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:icon', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        return jsonEncode({
          'type': 'icon',
          'name': data['name']?.toString() ?? 'extension',
          'size': (data['size'] as num?)?.toDouble() ?? 20,
          'style': data['style']?.toString(),
          'font': data['font']?.toString(),
          'pluginId':
              data['pluginId']?.toString() ?? PluginManager.activePluginId,
        });
      } catch (e) {
        _log.warning('ui.icon error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:link', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        return jsonEncode({
          'type': 'link',
          'label': data['label']?.toString() ?? '',
          'url': data['url']?.toString() ?? '',
        });
      } catch (e) {
        _log.warning('ui.link error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:input', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        return jsonEncode({
          'type': 'input',
          'label': data['label']?.toString(),
          'hint': data['hint']?.toString(),
          'callback': data['callback']?.toString(),
        });
      } catch (e) {
        _log.warning('ui.input error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:cloud_file', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        return jsonEncode({
          'type': 'cloud_file',
          'id': data['id']?.toString() ?? '',
          'fit': data['fit']?.toString() ?? 'cover',
        });
      } catch (e) {
        _log.warning('ui.cloud_file error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:plugin_asset', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final pluginId = PluginManager.activePluginId;
        final relativePath = data['path']?.toString() ?? '';
        if (pluginId == null || relativePath.isEmpty) return '{}';
        if (PluginManager().resolvePluginAsset(pluginId, relativePath) ==
            null) {
          _log.warning(
            'Plugin asset does not exist or escapes plugin folder: $relativePath',
          );
          return '{}';
        }
        return jsonEncode({
          'type': 'plugin_asset',
          'pluginId': pluginId,
          'path': relativePath,
          'kind': data['kind']?.toString(),
          'fit': data['fit']?.toString() ?? 'contain',
        });
      } catch (e) {
        _log.warning('ui.plugin_asset error: $e');
        return '{}';
      }
    });

    for (final type in const ['image', 'audio', 'video']) {
      runtime.onMessage('api:ui:$type', (args) {
        try {
          final data = args is String ? jsonDecode(args) : args;
          return jsonEncode({
            'type': 'asset_$type',
            'url': data['url']?.toString() ?? '',
            'filename': data['filename']?.toString(),
            'fit': data['fit']?.toString() ?? 'contain',
            'aspectRatio': (data['aspectRatio'] as num?)?.toDouble() ?? 16 / 9,
            'autoplay': data['autoplay'] == true,
          });
        } catch (e) {
          _log.warning('ui.$type error: $e');
          return '{}';
        }
      });
    }
  }
}
