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
    final items = await client.thoughts.getSequences(
      offset: fetchedCount,
      take: pageSize,
    );
    totalCount =
        (fetchedCount + items.length + (items.length == pageSize ? 1 : 0))
            .toInt();
    return items;
  }
}

class ThoughtSequenceSelector extends HookConsumerWidget {
  const ThoughtSequenceSelector({super.key, required this.onSequenceSelected});

  final Function(String) onSequenceSelected;

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
          final botName = sequence.botName;
          return ListTile(
            leading: botName != null && botName.isNotEmpty
                ? BotAvatarWidget(botName: botName, radius: 14)
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
                if (botName != null && botName.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BotNameWidget(
                        botName: botName,
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
