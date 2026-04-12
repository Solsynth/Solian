import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';

final thoughtSequenceListNotifierProvider = AsyncNotifierProvider.autoDispose(
  ThoughtSequenceListNotifier.new,
);

class ThoughtSequenceListNotifier
    extends AsyncNotifier<PaginationState<SnThinkingSequence>>
    with AsyncPaginationController<SnThinkingSequence> {
  static const int pageSize = 20;

  @override
  Future<List<SnThinkingSequence>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);

    final queryParams = {
      'offset': fetchedCount,
      'take': pageSize,
      'sort_by': 'last_message_at',
      'sort_order': 'desc',
    };

    final response = await client.dio.get(
      '/insight/thought/sequences',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data.map((json) => SnThinkingSequence.fromJson(json)).toList();
  }

  /// Deletes a sequence and refreshes the list
  Future<void> deleteSequence(String sequenceId) async {
    final client = ref.read(solarNetworkClientProvider);
    await client.thoughts.deleteSequence(sequenceId);
    refresh();
  }

  /// Updates the sharing settings of a sequence
  Future<void> updateSharing(String sequenceId, bool isPublic) async {
    final client = ref.read(solarNetworkClientProvider);
    await client.thoughts.updateSequence(
      sequenceId: sequenceId,
      data: {'is_public': isPublic},
    );
    refresh();
  }

  /// Marks a sequence as read
  Future<void> markAsRead(String sequenceId) async {
    final client = ref.read(solarNetworkClientProvider);
    await client.thoughts.markSequenceAsRead(sequenceId);
    refresh();
  }
}

class ThoughtSequenceSelector extends HookConsumerWidget {
  final Function(String) onSequenceSelected;

  const ThoughtSequenceSelector({super.key, required this.onSequenceSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = thoughtSequenceListNotifierProvider;
    return SheetScaffold(
      titleText: 'Select Conversation',
      child: PaginationList(
        provider: provider,
        notifier: provider.notifier,
        itemBuilder: (context, index, sequence) {
          return ListTile(
            title: Text(sequence.topic ?? 'Untitled Conversation'),
            subtitle: Text(sequence.createdAt.formatSystem()),
            onTap: () {
              onSequenceSelected(sequence.id);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}
