import 'dart:convert';

import 'package:island/shared/widgets/alert.dart' as alert;
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:logging/logging.dart';

final _log = Logger('NotifyApi');

/// Host-specific API: notification and alert UI for plugins.
///
/// Depends on Island's in-app alert/notification widgets, so it stays in the
/// main project rather than the foundation package.
class NotifyApi extends PluginApi {
  @override
  Set<PluginPermission> get requiredPermissions => {PluginPermission.notify};

  @override
  String jsBindingsFor(Set<PluginPermission> granted) {
    if (!granted.contains(PluginPermission.notify)) return '';
    return '''
function notify(title, body) {
  sendMessage("api:notify", JSON.stringify({title: title, body: body}));
}
function showAlert(message, title) {
  sendMessage("api:alert:show_alert", JSON.stringify({message: message, title: title || "Info"}));
}
function showError(message) {
  sendMessage("api:alert:show_error", JSON.stringify({message: message}));
}
function showConfirm(message, title) {
  sendMessage("api:alert:show_confirm", JSON.stringify({message: message, title: title || "Confirm"}));
}
''';
  }

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

    runtime.onMessage('api:alert:show_confirm', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final message = data['message']?.toString() ?? '';
        final title = data['title']?.toString() ?? 'Confirm';

        _log.info('Plugin show_confirm: $title');
        alert.showConfirmAlert(message, title);
      } catch (e) {
        _log.warning('Failed to show confirm: $e');
      }
    });
  }
}
