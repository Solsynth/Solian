import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post.dart';
import 'package:island/models/publisher.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/publishers_form.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/services/compose_storage_db.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/attachment_uploader.dart';
import 'package:island/widgets/content/attachment_preview.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/post/compose_shared.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/publishers_modal.dart';
import 'package:island/widgets/post/compose_settings_sheet.dart';
import 'package:island/widgets/post/compose_toolbar.dart';
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
    final publishers = ref.watch(publishersManagedProvider);

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

    // Initialize publisher once when data is available
    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        if (state.currentPublisher.value == null) {
          state.currentPublisher.value = publishers.value!.first;
        }
      }
      return null;
    }, [publishers]);

    // Load initial state if provided
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

    // Reset form to clean state for new composition
    void resetForm() {
      // Clear text fields
      state.titleController.clear();
      state.descriptionController.clear();
      state.contentController.clear();
      state.slugController.clear();

      // Reset visibility to default (0 = public)
      state.visibility.value = 0;

      // Clear attachments
      state.attachments.value = [];

      // Clear attachment progress
      state.attachmentProgress.value = {};

      // Clear tags
      state.tagsController.clearTags();

      // Clear categories
      state.categories.value = [];

      // Clear embed view
      state.embedView.value = null;

      // Clear poll
      state.pollId.value = null;

      // Clear realm
      state.realm.value = null;

      // Generate new draft ID for fresh composition
      // Note: We don't recreate the entire state, just reset the fields
      // The existing state object is reused for continuity
    }

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
      if (state.submitting.value) return;

      // Don't submit empty posts (no content and no attachments)
      final hasContent =
          state.titleController.text.trim().isNotEmpty ||
          state.descriptionController.text.trim().isNotEmpty ||
          state.contentController.text.trim().isNotEmpty;
      final hasAttachments = state.attachments.value.isNotEmpty;

      if (!hasContent && !hasAttachments) {
        // Show error message if context is mounted
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('postContentEmpty'.tr())));
        }
        return; // Don't submit empty posts
      }

      try {
        state.submitting.value = true;

        // Upload any local attachments first
        await Future.wait(
          state.attachments.value
              .asMap()
              .entries
              .where((entry) => entry.value.isOnDevice)
              .map(
                (entry) => ComposeLogic.uploadAttachment(ref, state, entry.key),
              ),
        );

        // Prepare API request
        final client = ref.read(apiClientProvider);
        final isNewPost = originalPost == null;
        final endpoint =
            '/sphere${isNewPost ? '/posts' : '/posts/${originalPost!.id}'}';

        // Create request payload
        final payload = {
          'title': state.titleController.text,
          'description': state.descriptionController.text,
          'content': state.contentController.text,
          if (state.slugController.text.isNotEmpty)
            'slug': state.slugController.text,
          'visibility': state.visibility.value,
          'attachments':
              state.attachments.value
                  .where((e) => e.isOnCloud)
                  .map((e) => e.data.id)
                  .toList(),
          'type': state.postType,
          if (repliedPost != null) 'replied_post_id': repliedPost.id,
          if (forwardedPost != null) 'forwarded_post_id': forwardedPost.id,
          'tags': state.tagsController.getTags,
          'categories': state.categories.value.map((e) => e.slug).toList(),
          if (state.realm.value != null) 'realm_id': state.realm.value?.id,
          if (state.pollId.value != null) 'poll_id': state.pollId.value,
          if (state.embedView.value != null)
            'embed_view': state.embedView.value!.toJson(),
        };

        // Send request
        final response = await client.request(
          endpoint,
          queryParameters: {'pub': state.currentPublisher.value?.name},
          data: payload,
          options: Options(method: isNewPost ? 'POST' : 'PATCH'),
        );

        // Create the post object from the response for the callback
        final post = SnPost.fromJson(response.data);

        // Mark as submitted
        submitted.value = true;

        // Delete draft after successful submission
        await ref
            .read(composeStorageNotifierProvider.notifier)
            .deleteDraft(state.draftId);

        // Reset the form for new composition
        resetForm();

        // Call the success callback with the created/updated post
        onSubmit?.call(post);
      } catch (err) {
        // Show error message if context is mounted
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $err')));
        }
        rethrow;
      } finally {
        state.submitting.value = false;
      }
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
            isCompact: true,
            item: state.attachments.value[idx],
            progress: progressMap[idx],
            onRequestUpload: () async {
              final config = await showModalBottomSheet<AttachmentUploadConfig>(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
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
                          useRootNavigator: true,
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

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
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
                  Text(
                    originalPost != null
                        ? 'postEditing'.tr()
                        : 'postCompose'.tr(),
                    style: theme.textTheme.titleMedium,
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
            _buildInfoBanner(context),

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
                              if (state.currentPublisher.value == null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        theme.colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Symbols.info,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const Gap(8),
                                      Expanded(
                                        child: Text(
                                          'Tap the avatar to create a publisher and start composing.',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              TextField(
                                controller: state.titleController,
                                enabled: state.currentPublisher.value != null,
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
                                enabled: state.currentPublisher.value != null,
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
                              TextField(
                                controller: state.contentController,
                                enabled: state.currentPublisher.value != null,
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

  Widget _buildInfoBanner(BuildContext context) {
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

    // Show banner for replies
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

    // Show banner for forwards
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
          useRootNavigator: true,
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
