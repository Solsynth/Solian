import 'dart:ffi';
import 'package:pocketpy/pocketpy_bindings_generated.dart';
import 'package:logging/logging.dart';
import 'package:island/plugin/bridge/py_bridge.dart';
import 'package:island/plugin/models/plugin_manifest.dart';
import 'package:island/plugin/apis/plugin_api.dart';
import 'package:island/shared/widgets/alert.dart' as alert;

final _log = Logger('NotifyApi');

/// Exposes a `notify(title, body)` function to Python plugins.
/// Shows real in-app notifications via the app's notification system.
class NotifyApi extends PluginApi {
  @override
  Set<PluginPermission> get requiredPermissions => {PluginPermission.notify};

  @override
  void register(Pointer<py_TValue> module, PyBridge py) {
    py.bindFunc(module, 'notify', Pointer.fromFunction(_notify, false));
  }

  static bool _notify(int argc, py_StackRef argv) {
    if (argc < 2) return false;
    final py = PyBridge.instance;
    final title = py.toDart(argv.elementAt(0))?.toString() ?? '';
    final body = py.toDart(argv.elementAt(1))?.toString() ?? '';

    _log.info('Plugin notify: $title - $body');

    try {
      alert.showNotification(title: title, content: body);
    } catch (e) {
      _log.warning('Failed to show notification: $e');
    }

    return true;
  }
}
