import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:island/plugins/bridge/js_bridge.dart';
import 'package:island/plugins/models/plugin_manifest.dart';
import 'package:island/plugins/apis/plugin_api.dart';
import 'package:island/plugins/plugin_manager.dart';

final _log = Logger('UiApi');

/// A UI descriptor returned by a plugin.
///
/// Plugins return structured data (JSON-like maps) that Dart renders as widgets.
class PluginUiDescriptor {
  final String type;
  final Map<String, dynamic> data;

  const PluginUiDescriptor({required this.type, required this.data});
}

/// Exposes UI building functions to JavaScript plugins.
///
/// Provides:
/// - `ui.card(title, body, actions=[])` - render a card
/// - `ui.list(items)` - render a list
/// - `ui.button(label, callback)` - create a button descriptor
/// - `ui.text(content)` - create a text descriptor
/// - `ui.section(title, children)` - create a section
/// - `ui.page(title, child)` - create a full-screen page descriptor
/// - `ui.row(children)`, `ui.column(children)` - compose elements
class UiApi extends PluginApi {
  @override
  Set<PluginPermission> get requiredPermissions => {PluginPermission.uiRender};

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
