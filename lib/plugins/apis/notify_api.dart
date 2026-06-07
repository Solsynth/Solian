import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:island/plugins/bridge/js_bridge.dart';
import 'package:island/plugins/models/plugin_manifest.dart';
import 'package:island/plugins/apis/plugin_api.dart';
import 'package:island/shared/widgets/alert.dart' as alert;

final _log = Logger('NotifyApi');

/// Exposes notification and alert functions to JavaScript plugins.
///
/// Available JS functions:
/// - `notify(title, body)` — show a real in-app notification
/// - `show_alert(message, title?)` — info dialog
/// - `show_error(message)` — error dialog
/// - `show_confirm(message, title?)` — returns true/false via sendMessage
class NotifyApi extends PluginApi {
  @override
  Set<PluginPermission> get requiredPermissions => {PluginPermission.notify};

  @override
  void register(JsRuntime runtime) {
    // notify(title, body) — real notification
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

    // show_alert(message, title?) — info dialog
    runtime.onMessage('api:alert:show_alert', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final message = data['message']?.toString() ?? '';
        final title = data['title']?.toString() ?? 'Info';

        _log.info('Plugin show_alert: $title');
        alert.showInfoAlert(message, title);
      } catch (e) {
        _log.warning('Failed to show alert: $e');
      }
    });

    // show_error(message) — error dialog
    runtime.onMessage('api:alert:show_error', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final message = data['message']?.toString() ?? 'Unknown error';

        _log.info('Plugin show_error: $message');
        alert.showErrorAlert(message);
      } catch (e) {
        _log.warning('Failed to show error: $e');
      }
    });

    // show_confirm(message, title?) — confirmation dialog, returns 'true'/'false'
    runtime.onMessage('api:alert:show_confirm', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final message = data['message']?.toString() ?? '';
        final title = data['title']?.toString() ?? 'Confirm';

        _log.info('Plugin show_confirm: $title');

        // Fire and forget — result is not easily returnable from async
        // in sendMessage. Plugins should use the callback pattern instead.
        alert.showConfirmAlert(message, title);
      } catch (e) {
        _log.warning('Failed to show confirm: $e');
      }
    });
  }
}
