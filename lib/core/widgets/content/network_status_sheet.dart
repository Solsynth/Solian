import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NetworkStatusSheet extends HookConsumerWidget {
  final bool autoClose;
  const NetworkStatusSheet({super.key, this.autoClose = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(websocketProvider);
    final wsState = ref.watch(websocketStateProvider);
    final apiState = ref.watch(networkStatusProvider);
    final serverUrl = ref.watch(serverUrlProvider);

    final wsNotifier = ref.watch(websocketStateProvider.notifier);

    final checks = [
      wsState == WebSocketState.connected(),
      apiState == NetworkStatus.online,
    ];

    useEffect(() {
      if (!autoClose) return;

      final checks = [
        wsState == WebSocketState.connected(),
        apiState == NetworkStatus.online,
      ];
      if (!checks.any((e) => !e)) {
        Future.delayed(Duration(seconds: 3), () {
          if (context.mounted) Navigator.of(context).pop();
        });
      }

      return null;
    }, [wsState, apiState]);

    return SheetScaffold(
      heightFactor: 0.6,
      titleText: !checks.any((e) => !e)
          ? 'Connection Status'
          : 'Connection Issues',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: !checks.any((e) => !e)
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('overview').tr().bold(),
                  Column(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!checks.any((e) => !e))
                        Text('Everything is operational.'),
                      if (!checks[0])
                        Text(
                          'WebSocket is disconnected. Realtime updates are not available. You can try tap the reconnect button below to try connect again.',
                        ),
                      if (!checks[1])
                        ...([
                          Text(
                            'API is unreachable, you can try again later. If the issue persists, please contact support. Or you can check the service status.',
                          ),
                          InkWell(
                            onTap: () {
                              launchUrlString("https://status.solsynth.dev");
                            },
                            child: Text(
                              'Check Service Status',
                            ).textColor(Colors.blueAccent).bold(),
                          ),
                        ]),
                    ],
                  ),
                ],
              ),
            ),
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
              spacing: 8,
              children: [
                Text('API').bold(),
                Text(
                  apiState == NetworkStatus.online
                      ? 'Online'
                      : apiState == NetworkStatus.notReady
                      ? 'Not Ready'
                      : apiState == NetworkStatus.maintenance
                      ? 'Under Maintenance'
                      : 'Offline',
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: apiState == NetworkStatus.online
                      ? Icon(
                          Symbols.check_circle,
                          key: ValueKey(NetworkStatus.online),
                          color: Colors.green,
                          size: 16,
                        )
                      : apiState == NetworkStatus.notReady
                      ? Icon(
                          Symbols.warning,
                          key: ValueKey(NetworkStatus.notReady),
                          color: Colors.orange,
                          size: 16,
                        )
                      : apiState == NetworkStatus.maintenance
                      ? Icon(
                          Symbols.construction,
                          key: ValueKey(NetworkStatus.maintenance),
                          color: Colors.orange,
                          size: 16,
                        )
                      : Icon(
                          Symbols.cloud_off,
                          key: ValueKey(NetworkStatus.offline),
                          color: Colors.red,
                          size: 16,
                        ),
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                Text('API Server').bold(),
                Expanded(child: Text(serverUrl)),
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
