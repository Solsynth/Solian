import 'dart:convert';
import 'dart:io' show Socket;
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/shared/widgets/app_scaffold.dart';

final mcServerStatusProvider = FutureProvider.autoDispose<McServerStatus>((
  ref,
) async {
  const host = '07f4acdef99b.ofalias.net';
  const port = 52062;
  final socket = await Socket.connect(
    host,
    port,
    timeout: const Duration(seconds: 5),
  );
  try {
    socket.write('LIST\n');
    final response = await socket.timeout(const Duration(seconds: 5)).first;
    final data = utf8.decode(response).trim();
    final parts = data.split('\x00');
    if (parts.length >= 2) {
      final json = jsonDecode(parts[1]);
      final description = json['description'] ?? '';
      final players = json['players']?['sample'] as List? ?? [];
      return McServerStatus(
        online: true,
        description: description is Map
            ? description['text'] ?? ''
            : description.toString(),
        playerCount: json['players']?['online'] ?? 0,
        maxPlayers: json['players']?['max'] ?? 0,
        players: players.map((p) => p['name'] as String).toList(),
      );
    }
    throw Exception('Invalid response');
  } finally {
    await socket.close();
  }
});

class McServerStatus {
  final bool online;
  final String description;
  final int playerCount;
  final int maxPlayers;
  final List<String> players;

  McServerStatus({
    required this.online,
    required this.description,
    required this.playerCount,
    required this.maxPlayers,
    required this.players,
  });
}

@RoutePage()
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(title: Text('game').tr()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_ServerStatusCard(), const Gap(16), _BlueMapCard()],
        ),
      ),
    );
  }
}

class _ServerStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(mcServerStatusProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dns, color: Theme.of(context).colorScheme.primary),
                const Gap(8),
                Text(
                  'mc_server_status',
                  style: Theme.of(context).textTheme.titleMedium,
                ).tr(),
              ],
            ),
            const Gap(12),
            statusAsync.when(
              data: (status) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: status.online ? Colors.green : Colors.red,
                        ),
                      ),
                      const Gap(8),
                      Text(status.online ? 'online' : 'offline').tr(),
                      if (status.online) ...[
                        const Gap(8),
                        Text('(${status.playerCount}/${status.maxPlayers})'),
                      ],
                    ],
                  ),
                  if (status.online && status.players.isNotEmpty) ...[
                    const Gap(12),
                    Text(
                      'players_online',
                      style: Theme.of(context).textTheme.bodySmall,
                    ).tr(),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: status.players.map((player) {
                        return Chip(
                          avatar: const Icon(Icons.person, size: 16),
                          label: Text(player),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(
                'server_unavailable',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ).tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlueMapCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.map, color: Theme.of(context).colorScheme.primary),
                const Gap(8),
                Text(
                  'bluemap',
                  style: Theme.of(context).textTheme.titleMedium,
                ).tr(),
              ],
            ),
          ),
          SizedBox(
            height: 400,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri('https://playmc.solsynth.dev/'),
              ),
              initialSettings: InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: true,
                allowsInlineMediaPlayback: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
