import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/compose_state_global.dart';
import 'package:island/posts/widgets/compose/compose_card.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/compose_state_utils.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ComposeSidebar extends HookConsumerWidget {
  final ComposeRequest request;
  final VoidCallback onClose;

  const ComposeSidebar({
    super.key,
    required this.request,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitted = useState(false);
    final showPreview = useState(false);

    final repliedPost =
        request.initialState?.replyingTo ?? request.originalPost?.repliedPost;
    final forwardedPost =
        request.initialState?.forwardingTo ??
        request.originalPost?.forwardedPost;

    final ComposeState composeState = useMemoized(
      () => ComposeLogic.createState(
        originalPost: request.originalPost,
        forwardedPost: forwardedPost,
        repliedPost: repliedPost,
        cloudDraftId: request.initialState?.cloudDraftId,
        postType: 0,
      ),
      [
        request.originalPost,
        forwardedPost,
        repliedPost,
        request.initialState?.cloudDraftId,
      ],
    );

    final stateNotifier = useMemoized(
      () => Listenable.merge([
        composeState.titleController,
        composeState.descriptionController,
        composeState.contentController,
        composeState.visibility,
        composeState.attachments,
        composeState.attachmentProgress,
        composeState.currentPublisher,
        composeState.submitting,
      ]),
      [composeState],
    );
    useListenable(stateNotifier);

    ComposeStateUtils.usePublisherInitialization(ref, composeState);
    ComposeStateUtils.useInitialStateLoader(composeState, request.initialState);

    useEffect(() {
      return () {
        if (!submitted.value &&
            request.originalPost == null &&
            composeState.currentPublisher.value != null) {
          ComposeLogic.saveDraftWithoutUpload(ref, composeState);
        }
        ComposeLogic.dispose(composeState);
      };
    }, []);

    void showSettingsSheet() {
      ComposeLogic.showSettingsSheet(context, composeState);
    }

    Future<void> performSubmit() async {
      await ComposeLogic.performSubmit(
        ref,
        composeState,
        context,
        originalPost: request.originalPost,
        repliedPost: repliedPost,
        forwardedPost: forwardedPost,
        onSuccess: () {
          submitted.value = true;
          request.completer.complete(true);
          onClose();
        },
      );
    }

    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.18),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.12),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  onPressed: () => showPreview.value = !showPreview.value,
                  icon: Icon(
                    showPreview.value ? Symbols.preview_off : Symbols.preview,
                    size: 20,
                  ),
                  tooltip: 'togglePreview'.tr(),
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  onPressed: showSettingsSheet,
                  icon: const Icon(Symbols.settings, size: 20),
                  tooltip: 'postSettings'.tr(),
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  onPressed:
                      (composeState.submitting.value ||
                          composeState.currentPublisher.value == null)
                      ? null
                      : performSubmit,
                  icon: composeState.submitting.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          request.originalPost != null
                              ? Symbols.edit
                              : Symbols.upload,
                          size: 20,
                        ),
                  tooltip: request.originalPost != null
                      ? 'postUpdate'.tr()
                      : 'postPublish'.tr(),
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    request.completer.complete(null);
                    onClose();
                  },
                  icon: const Icon(Symbols.close, size: 20),
                  tooltip: 'close'.tr(),
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: SizedBox.expand(
                key: ValueKey(showPreview.value),
                child: showPreview.value
                    ? _PostPreviewPane(state: composeState)
                    : PostComposeCard(
                        originalPost: request.originalPost,
                        initialState: request.initialState,
                        onSubmit: () {
                          submitted.value = true;
                          request.completer.complete(true);
                          onClose();
                        },
                        onCancel: () {
                          request.completer.complete(null);
                          onClose();
                        },
                        isContained: true,
                        showHeader: false,
                        providedState: composeState,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostPreviewPane extends HookWidget {
  final ComposeState state;

  const _PostPreviewPane({required this.state});

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
