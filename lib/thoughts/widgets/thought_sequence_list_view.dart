import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/thoughts/widgets/bot_avatar_widget.dart';
import 'package:island/thoughts/widgets/thought_sequence_list.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ThoughtSequenceListView extends HookConsumerWidget {
  const ThoughtSequenceListView({
    super.key,
    this.selectedSequenceId,
    this.onSequenceSelected,
  });

  final String? selectedSequenceId;
  final Function(String)? onSequenceSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = thoughtSequenceListNotifierProvider;
    final colorScheme = Theme.of(context).colorScheme;

    return PaginationList(
      padding: EdgeInsets.zero,
      provider: provider,
      notifier: provider.notifier,
      itemBuilder: (context, index, sequence) {
        final isSelected = sequence.id == selectedSequenceId;
        final botName = sequence.botName;

        return Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(64),
                  border: Border(
                    left: BorderSide(color: colorScheme.primary, width: 3),
                  ),
                )
              : null,
          child: ListTile(
            selected: isSelected,
            selectedColor: colorScheme.onPrimaryContainer,
            title: Text(
              sequence.topic ?? 'Untitled Conversation',
              style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
                      isSelected ? Symbols.chat_bubble : Symbols.chat_bubble_outline,
                      size: 16,
                      color: colorScheme.onSecondaryContainer,
                      fill: isSelected ? 1 : 0,
                    ),
                  ),
            onTap: () => onSequenceSelected?.call(sequence.id),
          ),
        );
      },
    );
  }
}
