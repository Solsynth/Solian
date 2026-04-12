import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/thoughts/widgets/thought_sequence_list.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// A widget that displays a list of thought sequences for sidebar selection.
///
/// This is different from [ThoughtSequenceSelector] which is used in a sheet
/// context. This widget is designed for the sidebar with selection highlighting.
class ThoughtSequenceListView extends HookConsumerWidget {
  final String? selectedSequenceId;
  final Function(String)? onSequenceSelected;

  const ThoughtSequenceListView({
    super.key,
    this.selectedSequenceId,
    this.onSequenceSelected,
  });

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
        final isUnread = _isUnread(sequence);

        return Dismissible(
          key: ValueKey(sequence.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Symbols.delete, color: colorScheme.onError),
          ),
          confirmDismiss: (_) => _confirmDelete(context, ref, sequence),
          child: Container(
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
              title: Row(
                children: [
                  if (sequence.agentInitiated)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Symbols.smart_toy,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      sequence.topic ?? 'Untitled Conversation',
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : isUnread
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                sequence.lastMessageAt.formatSystem(),
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              leading: Icon(
                isSelected
                    ? Symbols.chat_bubble
                    : isUnread
                    ? Symbols.mark_chat_unread
                    : Symbols.chat_bubble_outline,
                fill: isSelected || isUnread ? 1 : 0,
              ),
              trailing: sequence.isPublic
                  ? Icon(Symbols.public, size: 16, color: colorScheme.outline)
                  : null,
              onTap: () => onSequenceSelected?.call(sequence.id),
              onLongPress: () => _showOptions(context, ref, sequence),
            ),
          ),
        );
      },
    );
  }

  /// Checks if the sequence has unread messages
  bool _isUnread(SnThinkingSequence sequence) {
    if (sequence.userLastReadAt == null) return true;
    return sequence.lastMessageAt.isAfter(sequence.userLastReadAt!);
  }

  /// Shows confirmation dialog before deleting
  Future<bool> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SnThinkingSequence sequence,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteConversation'.tr()),
        content: Text('deleteConversationHint'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'delete'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(thoughtSequenceListNotifierProvider.notifier)
            .deleteSequence(sequence.id);
        showSnackBar('conversationDeleted'.tr());
        return true;
      } catch (e) {
        showSnackBar('failedToDeleteConversation'.tr());
        return false;
      }
    }
    return false;
  }

  /// Shows options menu for a sequence
  void _showOptions(
    BuildContext context,
    WidgetRef ref,
    SnThinkingSequence sequence,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                sequence.isPublic ? Symbols.public_off : Symbols.public,
              ),
              title: Text(
                sequence.isPublic
                    ? 'makeConversationPrivate'.tr()
                    : 'makeConversationPublic'.tr(),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await ref
                      .read(thoughtSequenceListNotifierProvider.notifier)
                      .updateSharing(sequence.id, !sequence.isPublic);
                  showSnackBar(
                    sequence.isPublic
                        ? 'conversationMadePrivate'.tr()
                        : 'conversationMadePublic'.tr(),
                  );
                } catch (e) {
                  showSnackBar('failedToUpdateSharing'.tr());
                }
              },
            ),
            ListTile(
              leading: const Icon(Symbols.delete, color: Colors.red),
              title: Text(
                'delete'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final shouldDelete = await _confirmDelete(
                  context,
                  ref,
                  sequence,
                );
                if (shouldDelete && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
