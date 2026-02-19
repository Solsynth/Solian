import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final composeLivestreamListProvider = FutureProvider.family
    .autoDispose<List<SnLiveStream>, String>((ref, publisherId) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get(
        '/sphere/livestreams/publisher/$publisherId',
        queryParameters: {'limit': 50, 'offset': 0},
      );

      return (response.data as List)
          .whereType<Map>()
          .map((e) => SnLiveStream.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });

class ComposeLivestreamSheet extends ConsumerWidget {
  final SnPublisher pub;

  const ComposeLivestreamSheet({super.key, required this.pub});

  String _statusText(SnLiveStreamStatus status) {
    return switch (status) {
      SnLiveStreamStatus.pending => 'Pending',
      SnLiveStreamStatus.active => 'Active',
      SnLiveStreamStatus.ended => 'Ended',
      SnLiveStreamStatus.error => 'Error',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamsAsync = ref.watch(composeLivestreamListProvider(pub.id));

    return SheetScaffold(
      heightFactor: 0.6,
      titleText: 'Livestream',
      child: streamsAsync.when(
        data: (streams) {
          if (streams.isEmpty) {
            return Center(
              child: Text(
                'No livestreams found for @${pub.name}. Create one in Creator Hub.',
              ),
            );
          }

          return ListView.builder(
            itemCount: streams.length,
            itemBuilder: (context, index) {
              final stream = streams[index];
              return ListTile(
                leading: const Icon(Symbols.live_tv),
                title: Text(stream.title ?? 'Untitled livestream'),
                subtitle: Text(
                  '${_statusText(stream.status)} · ${stream.viewerCount} viewers',
                ),
                trailing: const Icon(Symbols.chevron_right),
                onTap: () => Navigator.of(context).pop(stream),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
