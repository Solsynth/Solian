import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/websocket.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:styled_widget/styled_widget.dart';

class NetworkStatusSheet extends HookConsumerWidget {
  final bool autoClose;
  const NetworkStatusSheet({super.key, this.autoClose = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(websocketProvider);
    final wsState = ref.watch(websocketStateProvider);

    final wsNotifier = ref.watch(websocketStateProvider.notifier);

    useEffect(() {
      if (!autoClose) return;

      final checks = [wsState == WebSocketState.connected()];
      if (!checks.any((e) => !e)) {
        Future.delayed(Duration(seconds: 3), () {
          if (context.mounted) Navigator.of(context).pop();
        });
      }

      return null;
    }, [wsState]);

    return SheetScaffold(
      heightFactor: 0.6,
      titleText: wsState == WebSocketState.connected()
          ? 'Connection Status'
          : 'Connection Issue',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 8,
              children: [
                Text('WebSocket').bold(),
                wsState.when(
                  connected: () => Text('connectionConnected').tr(),
                  connecting: () => Text('connectionReconnecting').tr(),
                  disconnected: () => Text('connectionDisconnected').tr(),
                  serverDown: () => Text('connectionServerDown').tr(),
                  duplicateDevice: () => Text(
                    'Another device has connected with the same account.',
                  ),
                  error: (message) => Text('Connection error: $message'),
                ),
                if (ws.heartbeatDelay != null)
                  Text('${ws.heartbeatDelay!.inMilliseconds}ms'),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: wsState.when(
                    connected: () => Icon(
                      Symbols.check_circle,
                      key: ValueKey(WebSocketState.connected),
                      color: Colors.green,
                      size: 16,
                    ),
                    connecting: () => Icon(
                      Symbols.sync,
                      key: ValueKey(WebSocketState.connecting),
                      color: Colors.orange,
                      size: 16,
                    ),
                    disconnected: () => Icon(
                      Symbols.wifi_off,
                      key: ValueKey(WebSocketState.disconnected),
                      color: Colors.grey,
                      size: 16,
                    ),
                    serverDown: () => Icon(
                      Symbols.cloud_off,
                      key: ValueKey(WebSocketState.serverDown),
                      color: Colors.red,
                      size: 16,
                    ),
                    duplicateDevice: () => Icon(
                      Symbols.devices,
                      key: ValueKey(WebSocketState.duplicateDevice),
                      color: Colors.orange,
                      size: 16,
                    ),
                    error: (message) => Icon(
                      Symbols.error,
                      key: ValueKey(WebSocketState.error),
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                FilledButton.icon(
                  icon: const Icon(Symbols.wifi),
                  label: const Text('Reconnect'),
                  onPressed: () {
                    wsNotifier.manualReconnect();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
