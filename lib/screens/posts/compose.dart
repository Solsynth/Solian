import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/publishers.dart';
import 'package:island/screens/posts/detail.dart';
import 'package:island/services/file.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/attachment_preview.dart';
import 'package:island/widgets/post/publishers_modal.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pasteboard/pasteboard.dart';
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
  const PostComposeScreen({
    super.key,
    this.originalPost,
    this.repliedPost,
    this.forwardedPost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extract common theme and localization to avoid repeated lookups
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final publishers = ref.watch(publishersManagedProvider);
    final currentPublisher = useState<SnPublisher?>(null);

    // Initialize publisher once when data is available
    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        currentPublisher.value = publishers.value!.first;
      }
      return null;
    }, [publishers]);

    // State management
    final attachments = useState<List<UniversalFile>>(
      originalPost?.attachments
              .map(
                (e) => UniversalFile(
                  data: e,
                  type: switch (e.mimeType?.split('/').firstOrNull) {
                    'image' => UniversalFileType.image,
                    'video' => UniversalFileType.video,
                    'audio' => UniversalFileType.audio,
                    _ => UniversalFileType.file,
                  },
                ),
              )
              .toList() ??
          [],
    );
    final titleController = useTextEditingController(text: originalPost?.title);
    final descriptionController = useTextEditingController(
      text: originalPost?.description,
    );
    final contentController = useTextEditingController(
      text:
          originalPost?.content ??
          (forwardedPost != null ? '> ${forwardedPost!.content}\n\n' : null),
    );
    final visibility = useState<int>(originalPost?.visibility ?? 0);
    final submitting = useState(false);
    final attachmentProgress = useState<Map<int, double>>({});

    // Media handling functions
    Future<void> pickPhotoMedia() async {
      final result = await ref
          .watch(imagePickerProvider)
          .pickMultiImage(requestFullMetadata: true);
      if (result.isEmpty) return;
      attachments.value = [
        ...attachments.value,
        ...result.map(
          (e) => UniversalFile(data: e, type: UniversalFileType.image),
        ),
      ];
    }

    Future<void> pickVideoMedia() async {
      final result = await ref
          .watch(imagePickerProvider)
          .pickVideo(source: ImageSource.gallery);
      if (result == null) return;
      attachments.value = [
        ...attachments.value,
        UniversalFile(data: result, type: UniversalFileType.video),
      ];
    }

    // Helper method to get mimetype from file type
    String getMimeTypeFromFileType(UniversalFileType type) {
      return switch (type) {
        UniversalFileType.image => 'image/unknown',
        UniversalFileType.video => 'video/unknown',
        UniversalFileType.audio => 'audio/unknown',
        UniversalFileType.file => 'application/octet-stream',
      };
    }

    // Attachment management functions
    Future<void> uploadAttachment(int index) async {
      final attachment = attachments.value[index];
      if (attachment.isOnCloud) return;

      final baseUrl = ref.watch(serverUrlProvider);
      final token = await getToken(ref.watch(tokenProvider));
      if (token == null) throw ArgumentError('Token is null');

      try {
        // Update progress state
        attachmentProgress.value = {...attachmentProgress.value, index: 0};

        // Upload file to cloud
        final cloudFile =
            await putMediaToCloud(
              fileData: attachment,
              atk: token,
              baseUrl: baseUrl,
              filename: attachment.data.name ?? 'Post media',
              mimetype:
                  attachment.data.mimeType ??
                  getMimeTypeFromFileType(attachment.type),
              onProgress: (progress, _) {
                attachmentProgress.value = {
                  ...attachmentProgress.value,
                  index: progress,
                };
              },
            ).future;

        if (cloudFile == null) {
          throw ArgumentError('Failed to upload the file...');
        }

        // Update attachments list with cloud file
        final clone = List.of(attachments.value);
        clone[index] = UniversalFile(data: cloudFile, type: attachment.type);
        attachments.value = clone;
      } catch (err) {
        showErrorAlert(err);
      } finally {
        // Clean up progress state
        attachmentProgress.value = {...attachmentProgress.value}..remove(index);
      }
    }

    // Helper method to move attachment in the list
    List<UniversalFile> moveAttachment(
      List<UniversalFile> attachments,
      int idx,
      int delta,
    ) {
      if (idx + delta < 0 || idx + delta >= attachments.length) {
        return attachments;
      }
      final clone = List.of(attachments);
      clone.insert(idx + delta, clone.removeAt(idx));
      return clone;
    }

    Future<void> deleteAttachment(int index) async {
      final attachment = attachments.value[index];
      if (attachment.isOnCloud) {
        final client = ref.watch(apiClientProvider);
        await client.delete('/files/${attachment.data.id}');
      }
      final clone = List.of(attachments.value);
      clone.removeAt(index);
      attachments.value = clone;
    }

    // Form submission
    Future<void> performAction() async {
      if (submitting.value) return;

      try {
        submitting.value = true;

        // Upload any local attachments first
        await Future.wait(
          attachments.value
              .asMap()
              .entries
              .where((entry) => entry.value.isOnDevice)
              .map((entry) => uploadAttachment(entry.key)),
        );

        // Prepare API request
        final client = ref.watch(apiClientProvider);
        final isNewPost = originalPost == null;
        final endpoint = isNewPost ? '/posts' : '/posts/${originalPost!.id}';

        // Create request payload
        final payload = {
          'title': titleController.text,
          'description': descriptionController.text,
          'content': contentController.text,
          'visibility': visibility.value,
          'attachments':
              attachments.value
                  .where((e) => e.isOnCloud)
                  .map((e) => e.data.id)
                  .toList(),
          if (repliedPost != null) 'replied_post_id': repliedPost!.id,
          if (forwardedPost != null) 'forwarded_post_id': forwardedPost!.id,
        };

        // Send request
        await client.request(
          endpoint,
          data: payload,
          options: Options(
            headers: {'X-Pub': currentPublisher.value?.name},
            method: isNewPost ? 'POST' : 'PATCH',
          ),
        );

        if (context.mounted) {
          context.maybePop(true);
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    // Clipboard handling
    Future<void> handlePaste() async {
      final clipboard = await Pasteboard.image;
      if (clipboard == null) return;

      attachments.value = [
        ...attachments.value,
        UniversalFile(
          data: XFile.fromData(clipboard, mimeType: "image/jpeg"),
          type: UniversalFileType.image,
        ),
      ];
    }

    void handleKeyPress(RawKeyEvent event) {
      if (event is! RawKeyDownEvent) return;

      final isPaste = event.logicalKey == LogicalKeyboardKey.keyV;
      final isModifierPressed = event.isMetaPressed || event.isControlPressed;
      final isSubmit = event.logicalKey == LogicalKeyboardKey.enter;

      if (isPaste && isModifierPressed) {
        handlePaste();
      } else if (isSubmit && isModifierPressed && !submitting.value) {
        performAction();
      }
    }

    // Helper method to build visibility option
    Widget buildVisibilityOption(
      BuildContext context,
      int value,
      IconData icon,
      String textKey,
    ) {
      return ListTile(
        leading: Icon(icon),
        title: Text(textKey.tr()),
        onTap: () {
          visibility.value = value;
          Navigator.pop(context);
        },
        selected: visibility.value == value,
      );
    }

    // Helper method to get the appropriate icon for each visibility status
    IconData getVisibilityIcon(int visibilityValue) {
      switch (visibilityValue) {
        case 1: // Friends
          return Symbols.group;
        case 2: // Unlisted
          return Symbols.link_off;
        case 3: // Private
          return Symbols.lock;
        default: // Public (0) or unknown
          return Symbols.public;
      }
    }

    // Helper method to get the translation key for each visibility status
    String getVisibilityText(int visibilityValue) {
      switch (visibilityValue) {
        case 1: // Friends
          return 'postVisibilityFriends';
        case 2: // Unlisted
          return 'postVisibilityUnlisted';
        case 3: // Private
          return 'postVisibilityPrivate';
        default: // Public (0) or unknown
          return 'postVisibilityPublic';
      }
    }

    // Visibility handling
    void showVisibilityModal() {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('postVisibility'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildVisibilityOption(
                    context,
                    0,
                    Symbols.public,
                    'postVisibilityPublic',
                  ),
                  buildVisibilityOption(
                    context,
                    1,
                    Symbols.group,
                    'postVisibilityFriends',
                  ),
                  buildVisibilityOption(
                    context,
                    2,
                    Symbols.link_off,
                    'postVisibilityUnlisted',
                  ),
                  buildVisibilityOption(
                    context,
                    3,
                    Symbols.lock,
                    'postVisibilityPrivate',
                  ),
                ],
              ),
            ),
      );
    }

    // Show keyboard shortcuts dialog
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

    // Helper method to build wide attachment grid
    Widget buildWideAttachmentGrid(
      BoxConstraints constraints,
      List<UniversalFile> attachments,
      Map<int, double> progress,
    ) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var idx = 0; idx < attachments.length; idx++)
            SizedBox(
              width: constraints.maxWidth / 2 - 4,
              child: AttachmentPreview(
                item: attachments[idx],
                progress: progress[idx],
                onRequestUpload: () => uploadAttachment(idx),
                onDelete: () => deleteAttachment(idx),
                onMove: (delta) => moveAttachment(attachments, idx, delta),
              ),
            ),
        ],
      );
    }

    // Helper method to build narrow attachment list
    Widget buildNarrowAttachmentList(
      List<UniversalFile> attachments,
      Map<int, double> progress,
    ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          for (var idx = 0; idx < attachments.length; idx++)
            AttachmentPreview(
              item: attachments[idx],
              progress: progress[idx],
              onRequestUpload: () => uploadAttachment(idx),
              onDelete: () => deleteAttachment(idx),
              onMove: (delta) => moveAttachment(attachments, idx, delta),
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
          if (isWideScreen(context))
            Tooltip(
              message: 'keyboard_shortcuts'.tr(),
              child: IconButton(
                icon: const Icon(Symbols.keyboard),
                onPressed: showKeyboardShortcutsDialog,
              ),
            ),
          IconButton(
            onPressed: submitting.value ? null : performAction,
            icon:
                submitting.value
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
          if (repliedPost != null)
            _buildInfoBanner(
              context,
              Symbols.reply,
              'reply',
              repliedPost!.publisher.nick,
            ),
          if (forwardedPost != null)
            _buildInfoBanner(
              context,
              Symbols.forward,
              'forward',
              forwardedPost!.publisher.nick,
            ),

          // Main content area
          Expanded(
            child: Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Publisher profile picture
                GestureDetector(
                  child: ProfilePictureWidget(
                    fileId: currentPublisher.value?.picture?.id,
                    radius: 20,
                    fallbackIcon:
                        currentPublisher.value == null
                            ? Symbols.question_mark
                            : null,
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => PublisherModal(),
                    ).then((value) {
                      if (value is SnPublisher) currentPublisher.value = value;
                    });
                  },
                ).padding(top: 16),

                // Post content form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Visibility selector
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: showVisibilityModal,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: BorderSide(
                                  color: colorScheme.primary.withOpacity(0.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                visualDensity: const VisualDensity(
                                  vertical: -2,
                                  horizontal: -4,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    getVisibilityIcon(visibility.value),
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    getVisibilityText(visibility.value).tr(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ).padding(bottom: 6),

                        // Title field
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration.collapsed(
                            hintText: 'postTitle'.tr(),
                          ),
                          style: const TextStyle(fontSize: 16),
                          onTapOutside:
                              (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                        ),

                        // Description field
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration.collapsed(
                            hintText: 'postDescription'.tr(),
                          ),
                          style: const TextStyle(fontSize: 16),
                          onTapOutside:
                              (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                        ),

                        const Gap(8),

                        // Content field with keyboard listener
                        RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: handleKeyPress,
                          child: TextField(
                            controller: contentController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'postPlaceholder'.tr(),
                              isDense: true,
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
                                ? buildWideAttachmentGrid(
                                  constraints,
                                  attachments.value,
                                  attachmentProgress.value,
                                )
                                : buildNarrowAttachmentList(
                                  attachments.value,
                                  attachmentProgress.value,
                                );
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
                  onPressed: pickPhotoMedia,
                  icon: const Icon(Symbols.add_a_photo),
                  color: colorScheme.primary,
                ),
                IconButton(
                  onPressed: pickVideoMedia,
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

  // Helper method to build info banner for replied/forwarded posts
  Widget _buildInfoBanner(
    BuildContext context,
    IconData icon,
    String labelKey,
    String publisherNick,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const Gap(8),
          Expanded(
            child: Text(
              '${'labelKey'.tr()}: $publisherNick',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
