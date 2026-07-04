import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
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
    final connectivityStatus = ref.watch(connectivityStatusProvider);
    final hasConnectivity = hasNetworkConnectivityValue(connectivityStatus);
    final serverUrl = ref.watch(serverUrlProvider);

    final wsNotifier = ref.watch(websocketStateProvider.notifier);

    final checks = [
      hasConnectivity,
      wsState == WebSocketState.connected(),
      apiState == NetworkStatus.online,
    ];

    useEffect(() {
      if (!autoClose) return;

      final checks = [
        hasConnectivity,
        wsState == WebSocketState.connected(),
        apiState == NetworkStatus.online,
      ];
      if (!checks.any((e) => !e)) {
        Future.delayed(Duration(seconds: 3), () {
          if (context.mounted) Navigator.of(context).pop();
        });
      }

      return null;
    }, [wsState, apiState, hasConnectivity]);

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
                          'Your device is offline. Reconnect to Wi-Fi or cellular data to resume startup and realtime updates.',
                        ),
                      if (!checks[1])
                        Text(
                          'WebSocket is disconnected. Realtime updates are not available. You can try tap the reconnect button below to try connect again.',
                        ),
                      if (!checks[2])
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
                Text('Internet').bold(),
                Text(hasConnectivity ? 'Available' : 'Offline'),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: hasConnectivity
                      ? const Icon(
                          Symbols.check_circle,
                          color: Colors.green,
                          size: 16,
                        )
                      : const Icon(
                          Symbols.wifi_off,
                          color: Colors.red,
                          size: 16,
                        ),
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                Text('WebSocket').bold(),
                wsState.when(
                  connected: () => Text('connectionConnected').tr(),
                  connecting: () => Text('connectionReconnecting').tr(),
                  disconnected: () => Text('connectionDisconnected').tr(),
                  internetChanged: () => Text('connectionInternetChanged').tr(),
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
                      color: Colors.green,
                      size: 16,
                    ),
                    connecting: () =>
                        Icon(Symbols.sync, color: Colors.orange, size: 16),
                    disconnected: () =>
                        Icon(Symbols.wifi_off, color: Colors.grey, size: 16),
                    internetChanged: () =>
                        Icon(Symbols.wifi, color: Colors.amber, size: 16),
                    serverDown: () =>
                        Icon(Symbols.cloud_off, color: Colors.red, size: 16),
                    duplicateDevice: () =>
                        Icon(Symbols.devices, color: Colors.orange, size: 16),
                    error: (message) =>
                        Icon(Symbols.error, color: Colors.red, size: 16),
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
                          color: Colors.green,
                          size: 16,
                        )
                      : apiState == NetworkStatus.notReady
                      ? Icon(Symbols.warning, color: Colors.orange, size: 16)
                      : apiState == NetworkStatus.maintenance
                      ? Icon(
                          Symbols.construction,
                          color: Colors.orange,
                          size: 16,
                        )
                      : Icon(Symbols.cloud_off, color: Colors.red, size: 16),
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
                if (wsState == WebSocketState.connected())
                  OutlinedButton.icon(
                    icon: const Icon(Symbols.link_off),
                    label: const Text('Disconnect'),
                    onPressed: () {
                      wsNotifier.close();
                    },
                  ),
                if (wsState != WebSocketState.connected())
                  FilledButton.icon(
                    icon: const Icon(Symbols.wifi),
                    label: const Text('Connect'),
                    onPressed: hasConnectivity
                        ? () {
                            wsNotifier.connect();
                          }
                        : null,
                  ),
                if (wsState == WebSocketState.connected() ||
                    wsState == WebSocketState.disconnected() ||
                    wsState.when(
                      connected: () => false,
                      connecting: () => false,
                      disconnected: () => false,
                      internetChanged: () => false,
                      serverDown: () => false,
                      duplicateDevice: () => false,
                      error: (_) => true,
                    ))
                  FilledButton.icon(
                    icon: const Icon(Symbols.sync),
                    label: const Text('Reconnect'),
                    onPressed: hasConnectivity
                        ? () {
                            wsNotifier.manualReconnect();
                          }
                        : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
