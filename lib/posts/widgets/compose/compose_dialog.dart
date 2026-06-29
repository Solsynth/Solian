import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/shared/widgets/layouts/attention_modal_scaffold.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/posts/widgets/compose/compose_card.dart';
import 'package:island/posts/widgets/compose/compose_settings_sheet.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/compose_state_utils.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PostComposeDialog extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;
  final VoidCallback onCancel;
  final VoidCallback onSubmitted;

  const PostComposeDialog({
    super.key,
    required this.onCancel,
    required this.onSubmitted,
    this.originalPost,
    this.initialState,
  });

  static Future<bool?> show(
    BuildContext context, {
    SnPost? originalPost,
    PostComposeInitialState? initialState,
  }) {
    if (originalPost != null && originalPost.type == 1) {
      context.router.push(ArticleEditRoute(id: originalPost.id));
      return Future.value(true);
    }
    if (originalPost != null && originalPost.type == 2) {
      context.router.push(BlogEditRoute(id: originalPost.id));
      return Future.value(true);
    }

    final completer = Completer<bool?>();
    showAttentionModal(
      id: 'post-compose',
      replaceIfExists: true,
      barrierDismissible: true,
      builder: (overlayContext, dismiss) => PostComposeDialog(
        originalPost: originalPost,
        initialState: initialState,
        onCancel: () {
          if (!completer.isCompleted) completer.complete(null);
          dismiss();
        },
        onSubmitted: () {
          if (!completer.isCompleted) completer.complete(true);
          dismiss();
        },
      ),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(composeStorageProvider);
    final prompted = useState(false);
    final showPreview = useState(false);

    final fullPostData = originalPost != null
        ? ref.watch(postProvider(originalPost!.id))
        : const AsyncValue.data(null);

    final effectiveOriginalPost = fullPostData.when(
      data: (fullPost) => fullPost ?? originalPost,
      loading: () => originalPost,
      error: (_, _) => originalPost,
    );

    final repliedPost =
        initialState?.replyingTo ?? effectiveOriginalPost?.repliedPost;
    final forwardedPost =
        initialState?.forwardingTo ?? effectiveOriginalPost?.forwardedPost;

    final ComposeState state = useMemoized(
      () => ComposeLogic.createState(
        originalPost: effectiveOriginalPost,
        forwardedPost: forwardedPost,
        repliedPost: repliedPost,
        cloudDraftId: initialState?.cloudDraftId,
        postType: 0,
      ),
      [
        effectiveOriginalPost,
        forwardedPost,
        repliedPost,
        initialState?.cloudDraftId,
      ],
    );

    final stateNotifier = useMemoized(
      () => Listenable.merge([
        state.titleController,
        state.descriptionController,
        state.contentController,
        state.visibility,
        state.attachments,
        state.attachmentProgress,
        state.currentPublisher,
        state.submitting,
      ]),
      [state],
    );
    useListenable(stateNotifier);

    ComposeStateUtils.usePublisherInitialization(ref, state);
    ComposeStateUtils.useInitialStateLoader(state, initialState);

    useEffect(
      () {
        if (!prompted.value &&
            originalPost == null &&
            initialState?.replyingTo == null &&
            initialState?.forwardingTo == null) {
          final latestDraft = ref
              .read(composeStorageProvider.notifier)
              .getLatestDraftByType(0);
          if (latestDraft == null) return null;
          prompted.value = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showRestoreDialog(ref, state, latestDraft);
          });
        }
        return null;
      },
      [
        prompted.value,
        originalPost,
        initialState?.replyingTo,
        initialState?.forwardingTo,
      ],
    );

    useEffect(() {
      final isNewPost =
          effectiveOriginalPost == null &&
          repliedPost == null &&
          forwardedPost == null;
      if (isNewPost) {
        state.startAutoSave(ref);
      }
      return () {
        state.stopAutoSave();
        if (isNewPost) {
          ComposeLogic.saveDraftWithoutUpload(ref, state);
        }
        ComposeLogic.dispose(state);
      };
    }, [state, effectiveOriginalPost, repliedPost, forwardedPost]);

    void showSettingsSheet() {
      showAttentionModal(
        id: 'compose-settings',
        replaceIfExists: true,
        barrierDismissible: true,
        builder: (context, dismiss) => AttentionModalScaffold(
          titleText: 'postSettings'.tr(),
          onDismiss: dismiss,
          forceCard: true,
          child: ComposeSettingsSheet(state: state),
        ),
      );
    }

    Future<void> performSubmit() async {
      await ComposeLogic.submitInBackground(
        ref,
        state,
        originalPost: effectiveOriginalPost,
        repliedPost: repliedPost,
        forwardedPost: forwardedPost,
        onSubmitted: onSubmitted,
      );
    }

    final actions = [
      IconButton(
        icon: Icon(showPreview.value ? Symbols.preview_off : Symbols.preview),
        onPressed: () => showPreview.value = !showPreview.value,
        tooltip: 'togglePreview'.tr(),
      ),
      IconButton(
        icon: const Icon(Symbols.settings),
        onPressed: showSettingsSheet,
        tooltip: 'postSettings'.tr(),
      ),
      IconButton(
        onPressed:
            (state.submitting.value || state.currentPublisher.value == null)
            ? null
            : performSubmit,
        icon: state.submitting.value
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                effectiveOriginalPost != null ? Symbols.edit : Symbols.upload,
              ),
        tooltip: effectiveOriginalPost != null
            ? 'postUpdate'.tr()
            : 'postPublish'.tr(),
      ),
    ];

    return AttentionModalScaffold(
      titleText: 'postCompose'.tr(),
      actions: actions,
      onDismiss: onCancel,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: SizedBox.expand(
          key: ValueKey(showPreview.value),
          child: showPreview.value
              ? _DialogPreviewPane(state: state)
              : PostComposeCard(
                  originalPost: effectiveOriginalPost,
                  initialState: initialState,
                  onCancel: onCancel,
                  onSubmit: onSubmitted,
                  isContained: true,
                  showHeader: false,
                  providedState: state,
                  onSubmitRequest: performSubmit,
                ),
        ),
      ),
    );
  }

  Future<void> _showRestoreDialog(
    WidgetRef ref,
    ComposeState state,
    SnPost latestDraft,
  ) async {
    final restore = await showDialog<bool>(
      context: ref.context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        constraints: const BoxConstraints(maxWidth: 520),
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
      ComposeLogic.applyDraftToState(state, latestDraft);
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

class _DialogPreviewPane extends HookWidget {
  final ComposeState state;

  const _DialogPreviewPane({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = useValueListenable(state.contentController);
    final attachments = useValueListenable(state.attachments);

    if (content.text.isEmpty && attachments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.edit_note,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const Gap(12),
            Text(
              'previewEmpty'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: MarkdownTextContent(
        content: content.text,
        textStyle: theme.textTheme.bodyMedium,
        attachments: attachments
            .where((e) => e.isOnCloud)
            .map((e) => e.data)
            .cast<SnCloudFile>()
            .toList(),
      ),
    );
  }
}
