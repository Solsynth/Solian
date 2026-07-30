import 'dart:convert';

import 'package:island/shared/widgets/alert.dart' as alert;
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:logging/logging.dart';

final _log = Logger('NotifyApi');

class NotifyApi extends PluginApi {
  @override
  Set<PluginPermission> get requiredPermissions => {PluginPermission.notify};

  @override
  void register(PluginContext context, JsRuntime runtime) {
    runtime.exec('''
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
''');

    runtime.onMessage('api:notify', (raw) {
      try {
        final data = context.router.decode(raw);
        _log.info('Plugin notify: ${data['title']} - ${data['body']}');
        try {
          alert.showNotification(
            title: data['title']?.toString() ?? '',
            content: data['body']?.toString() ?? '',
          );
        } catch (e) {
          _log.warning('Failed to show notification: $e');
        }
      } catch (e) {
        _log.warning('Failed to parse notify args: $e');
      }
    });

    runtime.onMessage('api:alert:show_alert', (raw) {
      try {
        final data = context.router.decode(raw);
        alert.showInfoAlert(
          data['message']?.toString() ?? '',
          data['title']?.toString() ?? 'Info',
        );
      } catch (e) {
        _log.warning('Failed to show alert: $e');
      }
    });

    runtime.onMessage('api:alert:show_error', (raw) {
      try {
        final data = context.router.decode(raw);
        alert.showErrorAlert(data['message']?.toString() ?? 'Unknown error');
      } catch (e) {
        _log.warning('Failed to show error: $e');
      }
    });

    runtime.onMessage('api:alert:show_confirm', (raw) {
      try {
        final data = context.router.decode(raw);
        alert.showConfirmAlert(
          data['message']?.toString() ?? '',
          data['title']?.toString() ?? 'Confirm',
        );
      } catch (e) {
        _log.warning('Failed to show confirm: $e');
      }
    });
  }
}
