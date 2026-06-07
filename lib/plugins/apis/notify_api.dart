import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:island/plugins/bridge/js_bridge.dart';
import 'package:island/plugins/models/plugin_manifest.dart';
import 'package:island/plugins/apis/plugin_api.dart';
import 'package:island/shared/widgets/alert.dart' as alert;

final _log = Logger('NotifyApi');

/// Exposes a `notify(title, body)` function to JavaScript plugins.
/// Shows real in-app notifications via the app's notification system.
class NotifyApi extends PluginApi {
  @override
  Set<PluginPermission> get requiredPermissions => {PluginPermission.notify};

  @override
  void register(JsRuntime runtime) {
    runtime.onMessage('api:notify', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final title = data['title']?.toString() ?? '';
        final body = data['body']?.toString() ?? '';

        _log.info('Plugin notify: $title - $body');

        try {
          alert.showNotification(title: title, content: body);
        } catch (e) {
          _log.warning('Failed to show notification: $e');
        }
      } catch (e) {
        _log.warning('Failed to parse notify args: $e');
      }
    });
  }
}
