import 'dart:ffi';
import 'package:pocketpy/pocketpy.dart';
import 'package:pocketpy/pocketpy_bindings_generated.dart';
import 'package:island/plugin/bridge/py_bridge.dart';
import 'package:island/plugin/models/plugin_manifest.dart';
import 'package:island/plugin/apis/plugin_api.dart';

/// A UI descriptor returned by a plugin.
///
/// Plugins return structured data (JSON-like maps) that Dart renders as widgets.
class PluginUiDescriptor {
  final String type;
  final Map<String, dynamic> data;

  const PluginUiDescriptor({required this.type, required this.data});
}

/// Exposes UI building functions to Python plugins.
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
  void register(Pointer<py_TValue> module, PyBridge py) {
    py.bindFunc(module, 'card', Pointer.fromFunction(_card, false));
    py.bindFunc(module, 'list_items', Pointer.fromFunction(_listItems, false));
    py.bindFunc(module, 'button', Pointer.fromFunction(_button, false));
    py.bindFunc(module, 'text', Pointer.fromFunction(_text, false));
    py.bindFunc(module, 'section', Pointer.fromFunction(_section, false));
    py.bindFunc(module, 'divider', Pointer.fromFunction(_divider, false));
  }

  // All UI functions return JSON strings that describe the widget.
  // The Dart side parses these into actual Flutter widgets.

  static bool _card(int argc, py_StackRef argv) {
    if (argc < 2) return false;
    final py = PyBridge.instance;
    final title = py.toDart(argv.elementAt(0))?.toString() ?? '';
    final body = py.toDart(argv.elementAt(1))?.toString() ?? '';
    final actions = argc > 2 ? py.toDart(argv.elementAt(2)) : null;

    final result = <String, dynamic>{
      'type': 'card',
      'title': title,
      'body': body,
    };
    if (actions is List) {
      result['actions'] = actions;
    }

    final out = pocket.py_retval();
    py.newStr(out, _encode(result));
    return true;
  }

  static bool _listItems(int argc, py_StackRef argv) {
    if (argc < 1) return false;
    final py = PyBridge.instance;
    final items = py.toDart(argv.elementAt(0));

    final result = <String, dynamic>{
      'type': 'list',
      'items': items is List ? items : [items?.toString()],
    };

    final out = pocket.py_retval();
    py.newStr(out, _encode(result));
    return true;
  }

  static bool _button(int argc, py_StackRef argv) {
    if (argc < 2) return false;
    final py = PyBridge.instance;
    final label = py.toDart(argv.elementAt(0))?.toString() ?? '';
    final callback = py.toDart(argv.elementAt(1))?.toString();

    final result = <String, dynamic>{
      'type': 'button',
      'label': label,
    };
    if (callback != null) {
      result['callback'] = callback;
    }

    final out = pocket.py_retval();
    py.newStr(out, _encode(result));
    return true;
  }

  static bool _text(int argc, py_StackRef argv) {
    if (argc < 1) return false;
    final py = PyBridge.instance;
    final content = py.toDart(argv.elementAt(0))?.toString() ?? '';

    final result = <String, dynamic>{
      'type': 'text',
      'content': content,
    };

    final out = pocket.py_retval();
    py.newStr(out, _encode(result));
    return true;
  }

  static bool _section(int argc, py_StackRef argv) {
    if (argc < 2) return false;
    final py = PyBridge.instance;
    final title = py.toDart(argv.elementAt(0))?.toString() ?? '';
    final children = py.toDart(argv.elementAt(1));

    final result = <String, dynamic>{
      'type': 'section',
      'title': title,
      'children': children is List ? children : [],
    };

    final out = pocket.py_retval();
    py.newStr(out, _encode(result));
    return true;
  }

  static bool _divider(int argc, py_StackRef argv) {
    final py = PyBridge.instance;
    final out = pocket.py_retval();
    py.newStr(out, _encode({'type': 'divider'}));
    return true;
  }

  static String _encode(Map<String, dynamic> data) {
    try {
      // Simple JSON-like encoding (avoids importing dart:convert in FFI callback)
      final buffer = StringBuffer('{');
      final entries = data.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        buffer.write('"${entry.key}":');
        _writeJsonValue(buffer, entry.value);
        if (i < entries.length - 1) buffer.write(',');
      }
      buffer.write('}');
      return buffer.toString();
    } catch (e) {
      return '{}';
    }
  }

  static void _writeJsonValue(StringBuffer buffer, Object? value) {
    if (value == null) {
      buffer.write('null');
    } else if (value is String) {
      buffer.write('"${value.replaceAll('"', '\\"')}"');
    } else if (value is num || value is bool) {
      buffer.write(value);
    } else if (value is List) {
      buffer.write('[');
      for (int i = 0; i < value.length; i++) {
        _writeJsonValue(buffer, value[i]);
        if (i < value.length - 1) buffer.write(',');
      }
      buffer.write(']');
    } else if (value is Map) {
      buffer.write('{');
      final entries = value.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        buffer.write('"${entries[i].key}":');
        _writeJsonValue(buffer, entries[i].value);
        if (i < entries.length - 1) buffer.write(',');
      }
      buffer.write('}');
    } else {
      buffer.write('"${value.toString().replaceAll('"', '\\"')}"');
    }
  }
}
