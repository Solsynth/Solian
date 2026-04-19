import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/thoughts/widgets/bot_avatar_widget.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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
          final colorScheme = Theme.of(context).colorScheme;
          return ListTile(
            leading: sequence.botName != null && sequence.botName!.isNotEmpty
                ? BotAvatarWidget(botName: sequence.botName!, radius: 14)
                : Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Symbols.smart_toy,
                      size: 16,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
            title: Text(sequence.topic ?? 'Untitled Conversation'),
            subtitle: Row(
              children: [
                if (sequence.botName != null && sequence.botName!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BotNameWidget(
                        botName: sequence.botName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(8),
                    ],
                  ),
                Expanded(
                  child: Text(
                    sequence.lastMessageAt.formatSystem(),
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
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
