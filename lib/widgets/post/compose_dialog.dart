import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/services/compose_storage_db.dart';
import 'package:island/services/event_bus.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/post/compose_card.dart';

/// A dialog that wraps PostComposeCard for easy use in dialogs.
/// This provides a convenient way to show the compose interface in a modal dialog.
class PostComposeDialog extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;
  final bool isBottomSheet;

  const PostComposeDialog({
    super.key,
    this.originalPost,
    this.initialState,
    this.isBottomSheet = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    SnPost? originalPost,
    PostComposeInitialState? initialState,
  }) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.all(16),
            child: PostComposeDialog(
              originalPost: originalPost,
              initialState: initialState,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(composeStorageNotifierProvider);
    final restoredInitialState = useState<PostComposeInitialState?>(null);
    final prompted = useState(false);
    final isWide = isWideScreen(context);

    useEffect(() {
      if (!prompted.value &&
          originalPost == null &&
          initialState?.replyingTo == null &&
          initialState?.forwardingTo == null &&
          drafts.isNotEmpty) {
        prompted.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showRestoreDialog(ref, restoredInitialState);
        });
      }
      return null;
    }, [drafts, prompted.value]);

    return Dialog(
      insetPadding: isWide ? const EdgeInsets.all(16) : EdgeInsets.zero,
      child: ConstrainedBox(
        constraints:
            isWide
                ? const BoxConstraints(maxWidth: 600)
                : const BoxConstraints.expand(),
        child: PostComposeCard(
          originalPost: originalPost,
          initialState: restoredInitialState.value ?? initialState,
          onCancel: () => Navigator.of(context).pop(),
          onSubmit: () {
            // Fire event to notify listeners that a post was created
            eventBus.fire(PostCreatedEvent());
            Navigator.of(context).pop(true);
          },
          isDialog: true,
        ),
      ),
    );
  }

  Future<void> _showRestoreDialog(
    WidgetRef ref,
    ValueNotifier<PostComposeInitialState?> restoredInitialState,
  ) async {
    final drafts = ref.read(composeStorageNotifierProvider);
    if (drafts.isNotEmpty) {
      final latestDraft = drafts.values.last;

      final restore = await showDialog<bool>(
        context: ref.context,
        useRootNavigator: true,
        builder:
            (context) => AlertDialog(
              title: Text('restoreDraftTitle'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('restoreDraftMessage'.tr()),
                  const SizedBox(height: 16),
                  _buildCompactDraftPreview(context, latestDraft),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('no'.tr()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('yes'.tr()),
                ),
              ],
            ),
      );
      if (restore == true) {
        // Delete the old draft
        await ref
            .read(composeStorageNotifierProvider.notifier)
            .deleteDraft(latestDraft.id);
        restoredInitialState.value = PostComposeInitialState(
          title: latestDraft.title,
          description: latestDraft.description,
          content: latestDraft.content,
          visibility: latestDraft.visibility,
          attachments:
              latestDraft.attachments
                  .map((e) => UniversalFile.fromAttachment(e))
                  .toList(),
        );
      }
    }
  }

  Widget _buildCompactDraftPreview(BuildContext context, SnPost draft) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'draft'.tr(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (draft.title?.isNotEmpty ?? false)
            Text(
              draft.title!,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (draft.content?.isNotEmpty ?? false)
            Text(
              draft.content!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (draft.attachments.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.attach_file,
                  size: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${draft.attachments.length} attachment${draft.attachments.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
