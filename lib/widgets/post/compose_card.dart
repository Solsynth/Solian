import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post.dart';
import 'package:island/models/publisher.dart';
import 'package:island/screens/creators/publishers_form.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/services/compose_storage_db.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/post/compose_attachments.dart';
import 'package:island/widgets/post/compose_form_fields.dart';
import 'package:island/widgets/post/compose_info_banner.dart';
import 'package:island/widgets/post/compose_settings_sheet.dart';
import 'package:island/widgets/post/compose_shared.dart';
import 'package:island/widgets/post/compose_state_utils.dart';
import 'package:island/widgets/post/compose_submit_utils.dart';
import 'package:island/widgets/post/compose_toolbar.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/publishers_modal.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

/// A dialog-compatible card widget for post composition.
/// This extracts the core compose functionality from PostComposeScreen
/// and adapts it for use within dialogs or other constrained layouts.
class PostComposeCard extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;
  final VoidCallback? onCancel;
  final Function(SnPost)? onSubmit;
  final Function(ComposeState)? onStateChanged;
  final bool isInDialog;

  const PostComposeCard({
    super.key,
    this.originalPost,
    this.initialState,
    this.onCancel,
    this.onSubmit,
    this.onStateChanged,
    this.isInDialog = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitted = useState(false);

    final repliedPost = initialState?.replyingTo ?? originalPost?.repliedPost;
    final forwardedPost =
        initialState?.forwardingTo ?? originalPost?.forwardedPost;

    final theme = Theme.of(context);

    // Capture the notifier to avoid using ref after dispose
    final notifier = ref.read(composeStorageNotifierProvider.notifier);

    // Create compose state
    final state = useMemoized(
      () => ComposeLogic.createState(
        originalPost: originalPost,
        forwardedPost: forwardedPost,
        repliedPost: repliedPost,
        postType: 0,
      ),
      [originalPost, forwardedPost, repliedPost],
    );

    // Add a listener to the entire state to trigger rebuilds
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

    // Notify parent of state changes
    useEffect(() {
      onStateChanged?.call(state);
      return null;
    }, [state]);

    // Use shared state management utilities
    ComposeStateUtils.usePublisherInitialization(ref, state);
    ComposeStateUtils.useInitialStateLoader(state, initialState);

    // Dispose state when widget is disposed
    useEffect(() {
      return () {
        if (!submitted.value &&
            originalPost == null &&
            state.currentPublisher.value != null) {
          final hasContent =
              state.titleController.text.trim().isNotEmpty ||
              state.descriptionController.text.trim().isNotEmpty ||
              state.contentController.text.trim().isNotEmpty;
          final hasAttachments = state.attachments.value.isNotEmpty;
          if (hasContent || hasAttachments) {
            final draft = SnPost(
              id: state.draftId,
              title: state.titleController.text,
              description: state.descriptionController.text,
              content: state.contentController.text,
              visibility: state.visibility.value,
              type: state.postType,
              attachments:
                  state.attachments.value
                      .where((e) => e.isOnCloud)
                      .map((e) => e.data as SnCloudFile)
                      .toList(),
              publisher: state.currentPublisher.value!,
              updatedAt: DateTime.now(),
            );
            notifier
                .saveDraft(draft)
                .catchError((e) => debugPrint('Failed to save draft: $e'));
          }
        }
        ComposeLogic.dispose(state);
      };
    }, []);

    // Helper methods
    void showSettingsSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => ComposeSettingsSheet(state: state),
      );
    }

    Future<void> performSubmit() async {
      await ComposeSubmitUtils.performSubmit(
        ref,
        state,
        context,
        originalPost: originalPost,
        repliedPost: repliedPost,
        forwardedPost: forwardedPost,
        onSuccess: (SnPost createdPost) {
          // Mark as submitted
          submitted.value = true;

          // Delete draft after successful submission
          ref
              .read(composeStorageNotifierProvider.notifier)
              .deleteDraft(state.draftId);

          // Reset the form for new composition
          ComposeStateUtils.resetForm(state);

          // Call the widget's onSubmit callback to trigger activity list refresh
          onSubmit?.call(createdPost);
        },
      );
    }

    final maxHeight = math.min(
      640.0,
      MediaQuery.of(context).size.height * (isInDialog ? 0.8 : 0.72),
    );

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Gap(4),
                  Text(
                    'postCompose'.tr(),
                    style: theme.textTheme.titleMedium!.copyWith(fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Symbols.settings),
                    onPressed: showSettingsSheet,
                    tooltip: 'postSettings'.tr(),
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -2,
                    ),
                  ),
                  IconButton(
                    onPressed:
                        (state.submitting.value ||
                                state.currentPublisher.value == null)
                            ? null
                            : performSubmit,
                    icon:
                        state.submitting.value
                            ? SizedBox(
                              width: 24,
                              height: 24,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                            : Icon(
                              originalPost != null
                                  ? Symbols.edit
                                  : Symbols.upload,
                            ),
                    tooltip:
                        originalPost != null
                            ? 'postUpdate'.tr()
                            : 'postPublish'.tr(),
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -2,
                    ),
                  ),
                  if (onCancel != null)
                    IconButton(
                      icon: const Icon(Symbols.close),
                      onPressed: onCancel,
                      tooltip: 'cancel'.tr(),
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -2,
                      ),
                    ),
                ],
              ),
            ),

            // Info banner (reply/forward)
            ComposeInfoBanner(
              originalPost: originalPost,
              replyingTo: repliedPost,
              forwardingTo: forwardedPost,
              onReferencePostTap: (context, post) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder:
                      (context) => SheetScaffold(
                        titleText: 'Post Preview',
                        child: SingleChildScrollView(
                          child: PostItem(item: post),
                        ),
                      ),
                );
              },
            ),

            // Main content area
            Expanded(
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent:
                    (event) => ComposeLogic.handleKeyPress(
                      event,
                      state,
                      ref,
                      context,
                      originalPost: originalPost,
                      repliedPost: repliedPost,
                      forwardedPost: forwardedPost,
                    ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Row(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Publisher profile picture
                        GestureDetector(
                          child: ProfilePictureWidget(
                            fileId: state.currentPublisher.value?.picture?.id,
                            radius: 20,
                            fallbackIcon:
                                state.currentPublisher.value == null
                                    ? Symbols.question_mark
                                    : null,
                          ),
                          onTap: () {
                            if (state.currentPublisher.value == null) {
                              // No publisher loaded, guide user to create one
                              if (isInDialog) {
                                Navigator.of(context).pop();
                              }
                              context.pushNamed('creatorNew').then((value) {
                                if (value != null) {
                                  state.currentPublisher.value =
                                      value as SnPublisher;
                                  ref.invalidate(publishersManagedProvider);
                                }
                              });
                            } else {
                              // Show modal to select from existing publishers
                              showModalBottomSheet(
                                isScrollControlled: true,
                                useRootNavigator: true,
                                context: context,
                                builder: (context) => const PublisherModal(),
                              ).then((value) {
                                if (value != null) {
                                  state.currentPublisher.value = value;
                                }
                              });
                            }
                          },
                        ).padding(top: 8),

                        // Post content form
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ComposeFormFields(
                                state: state,
                                showPublisherAvatar: false,
                                onPublisherTap: () {
                                  if (state.currentPublisher.value == null) {
                                    // No publisher loaded, guide user to create one
                                    if (isInDialog) {
                                      Navigator.of(context).pop();
                                    }
                                    context.pushNamed('creatorNew').then((
                                      value,
                                    ) {
                                      if (value != null) {
                                        state.currentPublisher.value =
                                            value as SnPublisher;
                                        ref.invalidate(
                                          publishersManagedProvider,
                                        );
                                      }
                                    });
                                  } else {
                                    // Show modal to select from existing publishers
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      useRootNavigator: true,
                                      context: context,
                                      builder:
                                          (context) => const PublisherModal(),
                                    ).then((value) {
                                      if (value != null) {
                                        state.currentPublisher.value = value;
                                      }
                                    });
                                  }
                                },
                              ),
                              const Gap(8),
                              ComposeAttachments(state: state, isCompact: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom toolbar
            SizedBox(
              height: 65,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: ComposeToolbar(
                  state: state,
                  originalPost: originalPost,
                  isCompact: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
