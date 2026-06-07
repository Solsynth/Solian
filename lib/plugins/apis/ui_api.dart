import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:island/plugins/bridge/js_bridge.dart';
import 'package:island/plugins/models/plugin_manifest.dart';
import 'package:island/plugins/apis/plugin_api.dart';

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

        final result = <String, dynamic>{
          'type': 'button',
          'label': label,
        };
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
  }
}
