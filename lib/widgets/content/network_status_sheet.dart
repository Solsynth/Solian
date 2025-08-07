import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/websocket.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/widgets/content/sheet.dart';

class NetworkStatusSheet extends HookConsumerWidget {
  final VoidCallback onReconnect;

  const NetworkStatusSheet({super.key, required this.onReconnect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(websocketProvider);
    final wsState = ref.watch(websocketStateProvider);

    return SheetScaffold(
      titleText:
          wsState == WebSocketState.connected()
              ? 'Connection Status'
              : 'Connection Issue',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wsState.when(
              connected:
                  () => Text(
                    'Connected to server',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              connecting:
                  () => Text(
                    'Connecting to server...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              disconnected:
                  () => Text(
                    'Disconnected from server',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              serverDown:
                  () => Text(
                    'The server is not available right now... Please try again later...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              duplicateDevice:
                  () => Text(
                    'Another device has connected with the same account.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              error:
                  (message) => Text(
                    'Connection error: $message',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
            ),
            const SizedBox(height: 16),
            if (ws.heartbeatDelay != null)
              Text(
                'Last heartbeat: ${ws.heartbeatDelay!.inMilliseconds}ms',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 24),
            Center(
              child: FilledButton.icon(
                icon: const Icon(Symbols.wifi),
                label: const Text('Reconnect'),
                onPressed: () {
                  onReconnect();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
