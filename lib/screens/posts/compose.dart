import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post.dart';
import 'package:island/screens/creators/publishers.dart';
import 'package:island/screens/posts/compose_article.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/attachment_uploader.dart';
import 'package:island/widgets/content/attachment_preview.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/post/compose_shared.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/publishers_modal.dart';
import 'package:island/screens/posts/post_detail.dart';
import 'package:island/widgets/post/compose_settings_sheet.dart';
import 'package:island/services/compose_storage_db.dart';
// DraftManagerSheet is now imported through compose_toolbar.dart
import 'package:island/widgets/post/compose_toolbar.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

part 'compose.freezed.dart';
part 'compose.g.dart';

@freezed
sealed class PostComposeInitialState with _$PostComposeInitialState {
  const factory PostComposeInitialState({
    String? title,
    String? description,
    String? content,
    @Default([]) List<UniversalFile> attachments,
    int? visibility,
    SnPost? replyingTo,
    SnPost? forwardingTo,
  }) = _PostComposeInitialState;

  factory PostComposeInitialState.fromJson(Map<String, dynamic> json) =>
      _$PostComposeInitialStateFromJson(json);
}

class PostEditScreen extends HookConsumerWidget {
  final String id;
  const PostEditScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(id));
    return post.when(
      data: (post) => PostComposeScreen(originalPost: post),
      loading:
          () => AppScaffold(
            isNoBackground: false,
            appBar: AppBar(leading: const PageBackButton()),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, _) => AppScaffold(
            isNoBackground: false,
            appBar: AppBar(leading: const PageBackButton()),
            body: Text('Error: $e', textAlign: TextAlign.center),
          ),
    );
  }
}

class PostComposeScreen extends HookConsumerWidget {
  final SnPost? originalPost;
  final int? type;
  final PostComposeInitialState? initialState;
  const PostComposeScreen({
    super.key,
    this.type,
    this.initialState,
    this.originalPost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine the compose type: auto-detect from edited post or use query parameter
    final composeType = originalPost?.type ?? type ?? 0;
    final repliedPost = initialState?.replyingTo ?? originalPost?.repliedPost;
    final forwardedPost =
        initialState?.forwardingTo ?? originalPost?.forwardedPost;

    // If type is 1 (article), return ArticleComposeScreen
    if (composeType == 1) {
      return ArticleComposeScreen(originalPost: originalPost);
    }

    // Otherwise, continue with regular post compose
    final theme = Theme.of(context);

    // When editing, preserve the original replied/forwarded post references
    final effectiveRepliedPost = repliedPost ?? originalPost?.repliedPost;
    final effectiveForwardedPost = forwardedPost ?? originalPost?.forwardedPost;

    final publishers = ref.watch(publishersManagedProvider);
    final state = useMemoized(
      () => ComposeLogic.createState(
        originalPost: originalPost,
        forwardedPost: effectiveForwardedPost,
        repliedPost: effectiveRepliedPost,
        postType: 0, // Regular post type
      ),
      [originalPost, effectiveForwardedPost, effectiveRepliedPost],
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

    // Start auto-save when component mounts
    useEffect(() {
      if (originalPost == null) {
        // Only auto-save for new posts, not edits
        state.startAutoSave(ref);
      }
      return () => state.stopAutoSave();
    }, [state]);

    // Initialize publisher once when data is available
    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        if (state.currentPublisher.value == null) {
          // If no publisher is set, use the first available one
          state.currentPublisher.value = publishers.value!.first;
        }
      }
      return null;
    }, [publishers]);

    // Load initial state if provided (for sharing functionality)
    useEffect(() {
      if (initialState != null) {
        state.titleController.text = initialState!.title ?? '';
        state.descriptionController.text = initialState!.description ?? '';
        state.contentController.text = initialState!.content ?? '';
        if (initialState!.visibility != null) {
          state.visibility.value = initialState!.visibility!;
        }
        if (initialState!.attachments.isNotEmpty) {
          state.attachments.value = List.from(initialState!.attachments);
        }
      }
      return null;
    }, [initialState]);

    // Load draft if available (only for new posts without initial state)
    useEffect(() {
      if (originalPost == null &&
          effectiveForwardedPost == null &&
          effectiveRepliedPost == null &&
          initialState == null) {
        // Try to load the most recent draft
        final drafts = ref.read(composeStorageNotifierProvider);
        if (drafts.isNotEmpty) {
          final mostRecentDraft = drafts.values.reduce(
            (a, b) =>
                (a.updatedAt ?? DateTime(0)).isAfter(b.updatedAt ?? DateTime(0))
                    ? a
                    : b,
          );

          // Only load if the draft has meaningful content
          if (mostRecentDraft.content?.isNotEmpty == true ||
              mostRecentDraft.title?.isNotEmpty == true) {
            state.titleController.text = mostRecentDraft.title ?? '';
            state.descriptionController.text =
                mostRecentDraft.description ?? '';
            state.contentController.text = mostRecentDraft.content ?? '';
            state.visibility.value = mostRecentDraft.visibility;
          }
        }
      }
      return null;
    }, []);

    // Dispose state when widget is disposed
    useEffect(() {
      return () {
        state.stopAutoSave();
        ComposeLogic.dispose(state);
      };
    }, []);

    // Helper methods

    void showSettingsSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ComposeSettingsSheet(state: state),
      );
    }

    Widget buildWideAttachmentGrid() {
      return GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: state.attachments.value.length,
        itemBuilder: (context, idx) {
          final progressMap = state.attachmentProgress.value;
          return AttachmentPreview(
            item: state.attachments.value[idx],
            progress: progressMap[idx],
            onRequestUpload: () async {
              final config = await showModalBottomSheet<AttachmentUploadConfig>(
                context: context,
                isScrollControlled: true,
                builder:
                    (context) => AttachmentUploaderSheet(
                      ref: ref,
                      state: state,
                      index: idx,
                    ),
              );
              if (config != null) {
                await ComposeLogic.uploadAttachment(
                  ref,
                  state,
                  idx,
                  poolId: config.poolId,
                );
              }
            },
            onDelete: () => ComposeLogic.deleteAttachment(ref, state, idx),
            onUpdate:
                (value) => ComposeLogic.updateAttachment(state, value, idx),
            onMove: (delta) {
              state.attachments.value = ComposeLogic.moveAttachment(
                state.attachments.value,
                idx,
                delta,
              );
            },
          );
        },
      );
    }

    Widget buildNarrowAttachmentList() {
      return Column(
        children: [
          for (var idx = 0; idx < state.attachments.value.length; idx++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: () {
                final progressMap = state.attachmentProgress.value;
                return AttachmentPreview(
                  item: state.attachments.value[idx],
                  progress: progressMap[idx],
                  onRequestUpload: () async {
                    final config =
                        await showModalBottomSheet<AttachmentUploadConfig>(
                          context: context,
                          isScrollControlled: true,
                          builder:
                              (context) => AttachmentUploaderSheet(
                                ref: ref,
                                state: state,
                                index: idx,
                              ),
                        );
                    if (config != null) {
                      await ComposeLogic.uploadAttachment(
                        ref,
                        state,
                        idx,
                        poolId: config.poolId,
                      );
                    }
                  },
                  onDelete:
                      () => ComposeLogic.deleteAttachment(ref, state, idx),
                  onUpdate:
                      (value) =>
                          ComposeLogic.updateAttachment(state, value, idx),
                  onMove: (delta) {
                    state.attachments.value = ComposeLogic.moveAttachment(
                      state.attachments.value,
                      idx,
                      delta,
                    );
                  },
                );
              }(),
            ),
        ],
      );
    }

    // Build UI
    return PopScope(
      onPopInvoked: (_) {
        if (originalPost == null) {
          ComposeLogic.saveDraft(ref, state);
        }
      },
      child: AppScaffold(
        isNoBackground: false,
        appBar: AppBar(
          leading: const PageBackButton(),
          actions: [
            IconButton(
              icon: const Icon(Symbols.settings),
              onPressed: showSettingsSheet,
              tooltip: 'postSettings'.tr(),
            ),
            IconButton(
              onPressed:
                  state.submitting.value
                      ? null
                      : () => ComposeLogic.performAction(
                        ref,
                        state,
                        context,
                        originalPost: originalPost,
                        repliedPost: repliedPost,
                        forwardedPost: forwardedPost,
                      ),
              icon:
                  state.submitting.value
                      ? SizedBox(
                        width: 28,
                        height: 28,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ).center()
                      : Icon(
                        originalPost != null ? Symbols.edit : Symbols.upload,
                      ),
            ),
            const Gap(8),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reply/Forward info section
            _buildInfoBanner(context),

            // Main content area
            Expanded(
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
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => const PublisherModal(),
                        ).then((value) {
                          if (value != null) {
                            state.currentPublisher.value = value;
                          }
                        });
                      },
                    ).padding(top: 16),

                    // Post content form
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: state.titleController,
                                decoration: InputDecoration(
                                  hintText: 'postTitle'.tr(),
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                ),
                                style: theme.textTheme.titleMedium,
                                onTapOutside:
                                    (_) =>
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus(),
                              ),
                              TextField(
                                controller: state.descriptionController,
                                decoration: InputDecoration(
                                  hintText: 'postDescription'.tr(),
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    8,
                                    4,
                                    8,
                                    12,
                                  ),
                                ),
                                style: theme.textTheme.bodyMedium,
                                minLines: 1,
                                maxLines: 3,
                                onTapOutside:
                                    (_) =>
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus(),
                              ),
                              // Content field with borderless design
                              TextField(
                                controller: state.contentController,
                                style: theme.textTheme.bodyMedium,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'postContent'.tr(),
                                  isCollapsed: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                ),
                                maxLines: null,
                                onTapOutside:
                                    (_) =>
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus(),
                              ),

                              const Gap(8),

                              // Attachments preview
                              if (state.attachments.value.isNotEmpty)
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide = isWideScreen(context);
                                    return isWide
                                        ? buildWideAttachmentGrid()
                                        : buildNarrowAttachmentList();
                                  },
                                )
                              else
                                const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ).padding(horizontal: 16),
              ).alignment(Alignment.topCenter),
            ),

            // Bottom toolbar
            ComposeToolbar(state: state, originalPost: originalPost),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    // When editing, preserve the original replied/forwarded post references
    final effectiveRepliedPost =
        initialState?.replyingTo ?? originalPost?.repliedPost;
    final effectiveForwardedPost =
        initialState?.forwardingTo ?? originalPost?.forwardedPost;

    // Show editing banner when editing a post
    if (originalPost != null) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  Symbols.edit,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const Gap(8),
                Text(
                  'postEditing'.tr(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ).padding(horizontal: 16, vertical: 8),
          ),
          // Show reply/forward banners below editing banner if they exist
          if (effectiveRepliedPost != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Symbols.reply, size: 16),
                      const Gap(4),
                      Text(
                        'postReplyingTo'.tr(),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const Gap(8),
                  _buildCompactReferencePost(context, effectiveRepliedPost),
                ],
              ).padding(all: 16),
            ),
          if (effectiveForwardedPost != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Symbols.forward, size: 16),
                      const Gap(4),
                      Text(
                        'postForwardingTo'.tr(),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const Gap(8),
                  _buildCompactReferencePost(context, effectiveForwardedPost),
                ],
              ).padding(all: 16),
            ),
        ],
      );
    }

    // Show banner for replies (including when editing a reply)
    if (effectiveRepliedPost != null) {
      return Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.reply, size: 16),
                const Gap(4),
                Text(
                  'postReplyingTo'.tr(),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const Gap(8),
            _buildCompactReferencePost(context, effectiveRepliedPost),
          ],
        ).padding(all: 16),
      );
    }

    // Show banner for forwards (including when editing a forward)
    if (effectiveForwardedPost != null) {
      return Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.forward, size: 16),
                const Gap(4),
                Text(
                  'postForwardingTo'.tr(),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const Gap(8),
            _buildCompactReferencePost(context, effectiveForwardedPost),
          ],
        ).padding(all: 16),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCompactReferencePost(BuildContext context, SnPost post) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => DraggableScrollableSheet(
                initialChildSize: 0.7,
                maxChildSize: 0.9,
                minChildSize: 0.5,
                builder:
                    (context, scrollController) => Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              child: PostItem(item: post),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            ProfilePictureWidget(
              fileId: post.publisher.picture?.id,
              radius: 16,
            ),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.publisher.nick,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (post.title?.isNotEmpty ?? false)
                    Text(
                      post.title!,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (post.content?.isNotEmpty ?? false)
                    Text(
                      post.content!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (post.attachments.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.attach_file,
                          size: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const Gap(4),
                        Text(
                          'postHasAttachments'.plural(post.attachments.length),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Icon(
              Symbols.open_in_full,
              size: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
