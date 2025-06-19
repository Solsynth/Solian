import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/screens/creators/publishers.dart';
import 'package:island/screens/posts/compose_article.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/attachment_preview.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/post/compose_shared.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/publishers_modal.dart';
import 'package:island/screens/posts/detail.dart';
import 'package:island/widgets/post/compose_settings_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class PostEditScreen extends HookConsumerWidget {
  final String id;
  const PostEditScreen({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(id));
    return post.when(
      data: (post) => PostComposeScreen(originalPost: post),
      loading:
          () => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, _) => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: Text('Error: $e', textAlign: TextAlign.center),
          ),
    );
  }
}

@RoutePage()
class PostComposeScreen extends HookConsumerWidget {
  final SnPost? originalPost;
  final SnPost? repliedPost;
  final SnPost? forwardedPost;
  final int? type;
  const PostComposeScreen({
    super.key,
    this.originalPost,
    this.repliedPost,
    this.forwardedPost,
    @QueryParam('type') this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine the compose type: auto-detect from edited post or use query parameter
    final composeType = originalPost?.type ?? type ?? 0;

    // If type is 1 (article), return ArticleComposeScreen
    if (composeType == 1) {
      return ArticleComposeScreen(originalPost: originalPost);
    }

    // Otherwise, continue with regular post compose
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final publishers = ref.watch(publishersManagedProvider);
    final state = useMemoized(
      () => ComposeLogic.createState(
        originalPost: originalPost,
        forwardedPost: forwardedPost,
      ),
      [originalPost, forwardedPost],
    );

    // Initialize publisher once when data is available
    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        state.currentPublisher.value = publishers.value!.first;
      }
      return null;
    }, [publishers]);

    // Dispose state when widget is disposed
    useEffect(() {
      return () => ComposeLogic.dispose(state);
    }, []);

    // Helper methods

    void showSettingsSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder:
            (context) => ComposeSettingsSheet(
              titleController: state.titleController,
              descriptionController: state.descriptionController,
              visibility: state.visibility,
              onVisibilityChanged: () {
                // Trigger rebuild if needed
              },
            ),
      );
    }

    void showKeyboardShortcutsDialog() {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('keyboard_shortcuts'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ctrl/Cmd + Enter: ${'submit'.tr()}'),
                  Text('Ctrl/Cmd + V: ${'paste'.tr()}'),
                  Text('Ctrl/Cmd + I: ${'add_image'.tr()}'),
                  Text('Ctrl/Cmd + Shift + V: ${'add_video'.tr()}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('close'.tr()),
                ),
              ],
            ),
      );
    }

    Widget buildWideAttachmentGrid() {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: state.attachments.value.length,
        itemBuilder: (context, idx) {
          return AttachmentPreview(
            item: state.attachments.value[idx],
            progress: state.attachmentProgress.value[idx],
            onRequestUpload:
                () => ComposeLogic.uploadAttachment(ref, state, idx),
            onDelete: () => ComposeLogic.deleteAttachment(ref, state, idx),
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
              child: AttachmentPreview(
                item: state.attachments.value[idx],
                progress: state.attachmentProgress.value[idx],
                onRequestUpload:
                    () => ComposeLogic.uploadAttachment(ref, state, idx),
                onDelete: () => ComposeLogic.deleteAttachment(ref, state, idx),
                onMove: (delta) {
                  state.attachments.value = ComposeLogic.moveAttachment(
                    state.attachments.value,
                    idx,
                    delta,
                  );
                },
              ),
            ),
        ],
      );
    }

    // Build UI
    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title:
            isWideScreen(context)
                ? Text(originalPost != null ? 'editPost'.tr() : 'newPost'.tr())
                : null,
        actions: [
          IconButton(
            icon: const Icon(Symbols.settings),
            onPressed: showSettingsSheet,
            tooltip: 'postSettings'.tr(),
          ),
          if (isWideScreen(context))
            Tooltip(
              message: 'keyboard_shortcuts'.tr(),
              child: IconButton(
                icon: const Icon(Symbols.keyboard),
                onPressed: showKeyboardShortcutsDialog,
              ),
            ),
          ValueListenableBuilder<bool>(
            valueListenable: state.submitting,
            builder: (context, submitting, _) {
              return IconButton(
                onPressed:
                    submitting
                        ? null
                        : () => ComposeLogic.performAction(
                          ref,
                          state,
                          context,
                          originalPost: originalPost,
                          repliedPost: repliedPost,
                          forwardedPost: forwardedPost,
                          postType: 0, // Regular post type
                        ),
                icon:
                    submitting
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
              );
            },
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Content field with borderless design
                        RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey:
                              (event) => ComposeLogic.handleKeyPress(
                                event,
                                state,
                                ref,
                                context,
                                originalPost: originalPost,
                                repliedPost: repliedPost,
                                forwardedPost: forwardedPost,
                                postType: 0, // Regular post type
                              ),
                          child: TextField(
                            controller: state.contentController,
                            style: theme.textTheme.bodyMedium,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'postContent'.tr(),
                              contentPadding: const EdgeInsets.all(8),
                            ),
                            maxLines: null,
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                          ),
                        ),

                        const Gap(8),

                        // Attachments preview
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = isWideScreen(context);
                            return isWide
                                ? buildWideAttachmentGrid()
                                : buildNarrowAttachmentList();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).padding(horizontal: 16),
          ),

          // Bottom toolbar
          Material(
            elevation: 4,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => ComposeLogic.pickPhotoMedia(ref, state),
                  icon: const Icon(Symbols.add_a_photo),
                  color: colorScheme.primary,
                ),
                IconButton(
                  onPressed: () => ComposeLogic.pickVideoMedia(ref, state),
                  icon: const Icon(Symbols.videocam),
                  color: colorScheme.primary,
                ),
              ],
            ).padding(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              horizontal: 16,
              top: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    if (originalPost != null) {
      return Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  repliedPost != null ? Symbols.reply : Symbols.forward,
                  size: 16,
                ),
                const Gap(4),
                Text(
                  repliedPost != null
                      ? 'postReplyingTo'.tr()
                      : 'postForwardingTo'.tr(),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const Gap(8),
            PostItem(item: originalPost!, isOpenable: false),
          ],
        ).padding(all: 16),
      );
    }

    return const SizedBox.shrink();
  }
}
