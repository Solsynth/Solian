import 'dart:convert';

import 'package:island_plugin_foundation/src/apis/plugin_api.dart';
import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/bridge/plugin_context.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:island_plugin_foundation/src/plugin_manager.dart';
import 'package:logging/logging.dart';

final _log = Logger('UiApi');

class PluginUiDescriptor {
  final String type;
  final Map<String, dynamic> data;

  const PluginUiDescriptor({required this.type, required this.data});
}

class UiApi extends PluginApi {
  @override
  Set<PluginPermission> get requiredPermissions => {PluginPermission.uiRender};

  /// Called when a plugin calls [ui.open] to push content into a floating pane.
  /// Signature: (String title, Map<String, dynamic> descriptor, String pluginId)
  static void Function(String title, Map<String, dynamic> descriptor,
      String pluginId)? onOpenPane;

  @override
  void register(PluginContext context, JsRuntime runtime) {
    runtime.exec('''
var ui = ui || {};
ui.open = function(title, descriptor) {
  sendMessage("api:ui:open", JSON.stringify({title: title, descriptor: descriptor, pluginId: (typeof __plugin_id__ !== "undefined") ? __plugin_id__ : null}));
  return "";
};
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
''');

    _registerUiHandlers(context, runtime);
  }

  void _registerUiHandlers(PluginContext context, JsRuntime runtime) {
    runtime.onMessage('api:ui:card', (raw) {
      try {
        final data = context.decode(raw);
        final result = <String, dynamic>{
          'type': 'card',
          'title': data['title']?.toString() ?? '',
          'body': data['body']?.toString() ?? '',
        };
        final actions = data['actions'];
        if (actions is List && actions.isNotEmpty) {
          result['actions'] = actions;
        }
        return jsonEncode(result);
      } catch (e) {
        _log.warning('ui.card error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:list_items', (raw) {
      try {
        final data = context.decode(raw);
        final items = data['items'];
        return jsonEncode(<String, dynamic>{
          'type': 'list',
          'items': items is List ? items : [items?.toString()],
        });
      } catch (e) {
        _log.warning('ui.list_items error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:button', (raw) {
      try {
        final data = context.decode(raw);
        final result = <String, dynamic>{
          'type': 'button',
          'label': data['label']?.toString() ?? '',
        };
        final callback = data['callback']?.toString();
        if (callback != null) result['callback'] = callback;
        return jsonEncode(result);
      } catch (e) {
        _log.warning('ui.button error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:text', (raw) {
      try {
        final data = context.decode(raw);
        return jsonEncode({'type': 'text', 'content': data['content']?.toString() ?? ''});
      } catch (e) {
        _log.warning('ui.text error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:section', (raw) {
      try {
        final data = context.decode(raw);
        return jsonEncode(<String, dynamic>{
          'type': 'section',
          'title': data['title']?.toString() ?? '',
          'children': data['children'] is List ? data['children'] : [],
        });
      } catch (e) {
        _log.warning('ui.section error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:divider', (raw) {
      return jsonEncode({'type': 'divider'});
    });

    runtime.onMessage('api:ui:page', (raw) {
      try {
        final data = context.decode(raw);
        return jsonEncode(<String, dynamic>{
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
      runtime.onMessage('api:ui:$type', (raw) {
        try {
          final data = context.decode(raw);
          return jsonEncode(<String, dynamic>{
            'type': type,
            'children': data['children'] is List ? data['children'] : [],
          });
        } catch (e) {
          _log.warning('ui.$type error: $e');
          return '{}';
        }
      });
    }

    runtime.onMessage('api:ui:spacing', (raw) {
      try {
        final data = context.decode(raw);
        return jsonEncode(<String, dynamic>{
          'type': 'spacing',
          'size': (data['size'] as num?)?.toDouble() ?? 8,
        });
      } catch (e) {
        _log.warning('ui.spacing error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:icon', (raw) {
      try {
        final data = context.decode(raw);
        return jsonEncode(<String, dynamic>{
          'type': 'icon',
          'name': data['name']?.toString() ?? 'extension',
          'size': (data['size'] as num?)?.toDouble() ?? 20,
          'style': data['style']?.toString(),
          'font': data['font']?.toString(),
          'pluginId': data['pluginId']?.toString() ?? context.pluginId,
        });
      } catch (e) {
        _log.warning('ui.icon error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:link', (raw) {
      try {
        final data = context.decode(raw);
        return jsonEncode(<String, dynamic>{
          'type': 'link',
          'label': data['label']?.toString() ?? '',
          'url': data['url']?.toString() ?? '',
        });
      } catch (e) {
        _log.warning('ui.link error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:input', (raw) {
      try {
        final data = context.decode(raw);
        return jsonEncode(<String, dynamic>{
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

    runtime.onMessage('api:ui:cloud_file', (raw) {
      try {
        final data = context.decode(raw);
        return jsonEncode(<String, dynamic>{
          'type': 'cloud_file',
          'id': data['id']?.toString() ?? '',
          'fit': data['fit']?.toString() ?? 'cover',
        });
      } catch (e) {
        _log.warning('ui.cloud_file error: $e');
        return '{}';
      }
    });

    runtime.onMessage('api:ui:plugin_asset', (raw) {
      try {
        final data = context.decode(raw);
        final pluginId = context.pluginId;
        final relativePath = data['path']?.toString() ?? '';
        if (pluginId.isEmpty || relativePath.isEmpty) return '{}';
        if (PluginManager().resolvePluginAsset(pluginId, relativePath) == null) {
          _log.warning('Plugin asset does not exist or escapes plugin folder: $relativePath');
          return '{}';
        }
        return jsonEncode(<String, dynamic>{
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

    runtime.onMessage('api:ui:open', (raw) {
      try {
        final data = context.decode(raw);
        final title = data['title']?.toString() ?? '';
        final descriptorRaw = data['descriptor'];
        final pluginId = data['pluginId']?.toString() ?? context.pluginId;
        if (descriptorRaw is Map || descriptorRaw is String) {
          final desc = descriptorRaw is Map
              ? Map<String, dynamic>.from(descriptorRaw)
              : jsonDecode(descriptorRaw as String) as Map<String, dynamic>;
          if (desc['type'] is String) {
            onOpenPane?.call(title, desc, pluginId);
          }
        }
      } catch (e) {
        _log.warning('ui.open error: $e');
      }
      return '';
    });

    for (final type in const ['image', 'audio', 'video']) {
      runtime.onMessage('api:ui:$type', (raw) {
        try {
          final data = context.decode(raw);
          return jsonEncode(<String, dynamic>{
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
