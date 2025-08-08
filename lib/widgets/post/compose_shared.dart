import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post.dart';
import 'package:island/models/post_category.dart';
import 'package:island/models/publisher.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/file.dart';
import 'package:island/services/compose_storage_db.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/post/compose_link_attachments.dart';
import 'package:island/widgets/post/compose_poll.dart';
import 'package:island/widgets/post/compose_recorder.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'dart:async';
import 'dart:developer';

class ComposeState {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController contentController;
  final ValueNotifier<int> visibility;
  final ValueNotifier<List<UniversalFile>> attachments;
  final ValueNotifier<Map<int, double>> attachmentProgress;
  final ValueNotifier<SnPublisher?> currentPublisher;
  final ValueNotifier<bool> submitting;
  final ValueNotifier<List<PostCategory>> categories;
  StringTagController tagsController;
  final String draftId;
  int postType;
  // Linked poll id for this compose session (nullable)
  final ValueNotifier<String?> pollId;
  Timer? _autoSaveTimer;

  ComposeState({
    required this.titleController,
    required this.descriptionController,
    required this.contentController,
    required this.visibility,
    required this.attachments,
    required this.attachmentProgress,
    required this.currentPublisher,
    required this.submitting,
    required this.tagsController,
    required this.categories,
    required this.draftId,
    this.postType = 0,
    String? pollId,
  }) : pollId = ValueNotifier<String?>(pollId);

  void startAutoSave(WidgetRef ref) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      ComposeLogic.saveDraftWithoutUpload(ref, this);
    });
  }

  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  bool get isEmpty =>
      attachments.value.isEmpty && contentController.text.isEmpty;
}

class ComposeLogic {
  static ComposeState createState({
    SnPost? originalPost,
    SnPost? forwardedPost,
    SnPost? repliedPost,
    String? draftId,
    int postType = 0,
  }) {
    final id = draftId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final tagsController = StringTagController();
    originalPost?.tags.forEach((x) => tagsController.addTag(x.slug));
    return ComposeState(
      attachments: ValueNotifier<List<UniversalFile>>(
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
      ),
      titleController: TextEditingController(text: originalPost?.title),
      descriptionController: TextEditingController(
        text: originalPost?.description,
      ),
      contentController: TextEditingController(text: originalPost?.content),
      visibility: ValueNotifier<int>(originalPost?.visibility ?? 0),
      submitting: ValueNotifier<bool>(false),
      attachmentProgress: ValueNotifier<Map<int, double>>({}),
      currentPublisher: ValueNotifier<SnPublisher?>(originalPost?.publisher),
      tagsController: tagsController,
      categories: ValueNotifier<List<PostCategory>>(
        originalPost?.categories ?? [],
      ),
      draftId: id,
      postType: postType,
      // initialize without poll by default
      pollId: null,
    );
  }

  static ComposeState createStateFromDraft(SnPost draft, {int postType = 0}) {
    final tagsController = StringTagController();
    final categoriesController = StringTagController();
    for (var x in draft.tags) {
      tagsController.addTag(x.slug);
    }
    for (var x in draft.categories) {
      categoriesController.addTag(x.slug);
    }
    return ComposeState(
      attachments: ValueNotifier<List<UniversalFile>>(
        draft.attachments.map((e) => UniversalFile.fromAttachment(e)).toList(),
      ),
      titleController: TextEditingController(text: draft.title),
      descriptionController: TextEditingController(text: draft.description),
      contentController: TextEditingController(text: draft.content),
      visibility: ValueNotifier<int>(draft.visibility),
      submitting: ValueNotifier<bool>(false),
      attachmentProgress: ValueNotifier<Map<int, double>>({}),
      currentPublisher: ValueNotifier<SnPublisher?>(null),
      tagsController: tagsController,
      categories: ValueNotifier<List<PostCategory>>([]),
      draftId: draft.id,
      postType: postType,
      pollId: null,
    );
  }

  static Future<void> saveDraft(WidgetRef ref, ComposeState state) async {
    final hasContent =
        state.titleController.text.trim().isNotEmpty ||
        state.descriptionController.text.trim().isNotEmpty ||
        state.contentController.text.trim().isNotEmpty;
    final hasAttachments = state.attachments.value.isNotEmpty;

    if (!hasContent && !hasAttachments) {
      return; // Don't save empty posts
    }

    try {
      if (state._autoSaveTimer == null) {
        return;
      }

      // Upload any local attachments first
      final baseUrl = ref.watch(serverUrlProvider);
      final token = await getToken(ref.watch(tokenProvider));
      if (token == null) throw ArgumentError('Token is null');

      for (int i = 0; i < state.attachments.value.length; i++) {
        final attachment = state.attachments.value[i];
        if (attachment.data is! SnCloudFile) {
          try {
            final cloudFile =
                await putMediaToCloud(
                  fileData: attachment,
                  atk: token,
                  baseUrl: baseUrl,
                  filename:
                      attachment.data.name ??
                      (state.postType == 1 ? 'Article media' : 'Post media'),
                  mimetype:
                      attachment.data.mimeType ??
                      ComposeLogic.getMimeTypeFromFileType(attachment.type),
                ).future;
            if (cloudFile != null) {
              // Update attachments list with cloud file
              final clone = List.of(state.attachments.value);
              clone[i] = UniversalFile(data: cloudFile, type: attachment.type);
              state.attachments.value = clone;
            }
          } catch (err) {
            log('[ComposeLogic] Failed to upload attachment: $err');
            // Continue with other attachments even if one fails
          }
        }
      }

      final draft = SnPost(
        id: state.draftId,
        title: state.titleController.text,
        description: state.descriptionController.text,
        language: null,
        editedAt: null,
        publishedAt: DateTime.now(),
        visibility: state.visibility.value,
        content: state.contentController.text,
        type: state.postType,
        meta: null,
        viewsUnique: 0,
        viewsTotal: 0,
        upvotes: 0,
        downvotes: 0,
        repliesCount: 0,
        threadedPostId: null,
        threadedPost: null,
        repliedPostId: null,
        repliedPost: null,
        forwardedPostId: null,
        forwardedPost: null,
        attachments:
            state.attachments.value
                .map((e) => e.data)
                .whereType<SnCloudFile>()
                .toList(),
        publisher: SnPublisher(
          id: '',
          type: 0,
          name: '',
          nick: '',
          picture: null,
          background: null,
          account: null,
          accountId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          deletedAt: null,
          realmId: null,
          verification: null,
        ),
        reactions: [],
        tags: [],
        categories: [],
        collections: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
      );

      await ref.read(composeStorageNotifierProvider.notifier).saveDraft(draft);
    } catch (e) {
      log('[ComposeLogic] Failed to save draft, error: $e');
    }
  }

  static Future<void> saveDraftWithoutUpload(
    WidgetRef ref,
    ComposeState state,
  ) async {
    final hasContent =
        state.titleController.text.trim().isNotEmpty ||
        state.descriptionController.text.trim().isNotEmpty ||
        state.contentController.text.trim().isNotEmpty;
    final hasAttachments = state.attachments.value.isNotEmpty;

    if (!hasContent && !hasAttachments) {
      return; // Don't save empty posts
    }

    try {
      if (state._autoSaveTimer == null) {
        return;
      }

      final draft = SnPost(
        id: state.draftId,
        title: state.titleController.text,
        description: state.descriptionController.text,
        language: null,
        editedAt: null,
        publishedAt: DateTime.now(),
        visibility: state.visibility.value,
        content: state.contentController.text,
        type: state.postType,
        meta: null,
        viewsUnique: 0,
        viewsTotal: 0,
        upvotes: 0,
        downvotes: 0,
        repliesCount: 0,
        threadedPostId: null,
        threadedPost: null,
        repliedPostId: null,
        repliedPost: null,
        forwardedPostId: null,
        forwardedPost: null,
        attachments:
            state.attachments.value
                .map((e) => e.data)
                .whereType<SnCloudFile>()
                .toList(),
        publisher: SnPublisher(
          id: '',
          type: 0,
          name: '',
          nick: '',
          picture: null,
          background: null,
          account: null,
          accountId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          deletedAt: null,
          realmId: null,
          verification: null,
        ),
        reactions: [],
        tags: [],
        categories: [],
        collections: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
      );

      await ref.read(composeStorageNotifierProvider.notifier).saveDraft(draft);
    } catch (e) {
      log('[ComposeLogic] Failed to save draft without upload, error: $e');
    }
  }

  static Future<void> saveDraftManually(
    WidgetRef ref,
    ComposeState state,
    BuildContext context,
  ) async {
    try {
      await saveDraft(ref, state);

      if (context.mounted) {
        showSnackBar('draftSaved'.tr());
      }
    } catch (e) {
      log('[ComposeLogic] Failed to save draft manually, error: $e');
      if (context.mounted) {
        showSnackBar('draftSaveFailed'.tr());
      }
    }
  }

  static Future<void> deleteDraft(WidgetRef ref, String draftId) async {
    try {
      await ref
          .read(composeStorageNotifierProvider.notifier)
          .deleteDraft(draftId);
    } catch (e) {
      // Silently fail
    }
  }

  static Future<SnPost?> loadDraft(WidgetRef ref, String draftId) async {
    try {
      return ref
          .read(composeStorageNotifierProvider.notifier)
          .getDraft(draftId);
    } catch (e) {
      return null;
    }
  }

  static String getMimeTypeFromFileType(UniversalFileType type) {
    return switch (type) {
      UniversalFileType.image => 'image/unknown',
      UniversalFileType.video => 'video/unknown',
      UniversalFileType.audio => 'audio/unknown',
      UniversalFileType.file => 'application/octet-stream',
    };
  }

  static Future<void> pickPhotoMedia(WidgetRef ref, ComposeState state) async {
    final result = await ref
        .watch(imagePickerProvider)
        .pickMultiImage(requestFullMetadata: true);
    if (result.isEmpty) return;
    state.attachments.value = [
      ...state.attachments.value,
      ...result.map(
        (e) => UniversalFile(data: e, type: UniversalFileType.image),
      ),
    ];
  }

  static Future<void> pickVideoMedia(WidgetRef ref, ComposeState state) async {
    final result = await ref
        .watch(imagePickerProvider)
        .pickVideo(source: ImageSource.gallery);
    if (result == null) return;
    state.attachments.value = [
      ...state.attachments.value,
      UniversalFile(data: result, type: UniversalFileType.video),
    ];
  }

  static Future<void> recordAudioMedia(
    WidgetRef ref,
    ComposeState state,
    BuildContext context,
  ) async {
    final audioPath = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => ComposeRecorder(),
    );
    if (audioPath == null) return;

    state.attachments.value = [
      ...state.attachments.value,
      UniversalFile(
        data: XFile(audioPath, mimeType: 'audio/m4a'),
        type: UniversalFileType.audio,
      ),
    ];
  }

  static Future<void> linkAttachment(
    WidgetRef ref,
    ComposeState state,
    BuildContext context,
  ) async {
    final cloudFile = await showModalBottomSheet<SnCloudFile?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => ComposeLinkAttachment(),
    );
    if (cloudFile == null) return;

    state.attachments.value = [
      ...state.attachments.value,
      UniversalFile(
        data: cloudFile,
        type: switch (cloudFile.mimeType?.split('/').firstOrNull) {
          'image' => UniversalFileType.image,
          'video' => UniversalFileType.video,
          'audio' => UniversalFileType.audio,
          _ => UniversalFileType.file,
        },
        isLink: true,
      ),
    ];
  }

  static void updateAttachment(
    ComposeState state,
    UniversalFile value,
    int index,
  ) {
    state.attachments.value =
        state.attachments.value.mapIndexed((idx, ele) {
          if (idx == index) return value;
          return ele;
        }).toList();
  }

  static Future<void> uploadAttachment(
    WidgetRef ref,
    ComposeState state,
    int index,
  ) async {
    final attachment = state.attachments.value[index];
    if (attachment.isOnCloud) return;

    final baseUrl = ref.watch(serverUrlProvider);
    final token = await getToken(ref.watch(tokenProvider));
    if (token == null) throw ArgumentError('Token is null');

    try {
      // Update progress state
      state.attachmentProgress.value = {
        ...state.attachmentProgress.value,
        index: 0,
      };

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
              state.attachmentProgress.value = {
                ...state.attachmentProgress.value,
                index: progress,
              };
            },
          ).future;

      if (cloudFile == null) {
        throw ArgumentError('Failed to upload the file...');
      }

      // Update attachments list with cloud file
      final clone = List.of(state.attachments.value);
      clone[index] = UniversalFile(data: cloudFile, type: attachment.type);
      state.attachments.value = clone;
    } catch (err) {
      showErrorAlert(err);
    } finally {
      // Clean up progress state
      state.attachmentProgress.value = {...state.attachmentProgress.value}
        ..remove(index);
    }
  }

  static List<UniversalFile> moveAttachment(
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

  static Future<void> deleteAttachment(
    WidgetRef ref,
    ComposeState state,
    int index,
  ) async {
    final attachment = state.attachments.value[index];
    if (attachment.isOnCloud && !attachment.isLink) {
      final client = ref.watch(apiClientProvider);
      await client.delete('/drive/files/${attachment.data.id}');
    }
    final clone = List.of(state.attachments.value);
    clone.removeAt(index);
    state.attachments.value = clone;
  }

  static void insertAttachment(WidgetRef ref, ComposeState state, int index) {
    final attachment = state.attachments.value[index];
    if (!attachment.isOnCloud) {
      return;
    }
    final cloudFile = attachment.data as SnCloudFile;
    final markdown = '![${cloudFile.name}](solian://files/${cloudFile.id})';
    final controller = state.contentController;
    final text = controller.text;
    final selection = controller.selection;
    final newText = text.replaceRange(selection.start, selection.end, markdown);
    controller.text = newText;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: selection.start + markdown.length),
    );
  }

  static Future<void> pickPoll(
    WidgetRef ref,
    ComposeState state,
    BuildContext context,
  ) async {
    if (state.pollId.value != null) {
      state.pollId.value = null;
      return;
    }

    final poll = await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const ComposePollSheet(),
    );

    if (poll == null) return;
    state.pollId.value = poll.id;
  }

  static Future<void> performAction(
    WidgetRef ref,
    ComposeState state,
    BuildContext context, {
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
  }) async {
    if (state.submitting.value) return;

    // Don't submit empty posts (no content and no attachments)
    final hasContent =
        state.titleController.text.trim().isNotEmpty ||
        state.descriptionController.text.trim().isNotEmpty ||
        state.contentController.text.trim().isNotEmpty;
    final hasAttachments = state.attachments.value.isNotEmpty;

    if (!hasContent && !hasAttachments) {
      if (context.mounted) {
        showSnackBar('postContentEmpty'.tr());
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
            .map((entry) => uploadAttachment(ref, state, entry.key)),
      );

      // Prepare API request
      final client = ref.watch(apiClientProvider);
      final isNewPost = originalPost == null;
      final endpoint =
          '/sphere${isNewPost ? '/posts' : '/posts/${originalPost.id}'}';

      // Create request payload
      final payload = {
        'title': state.titleController.text,
        'description': state.descriptionController.text,
        'content': state.contentController.text,
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
        if (state.pollId.value != null) 'poll_id': state.pollId.value,
      };

      // Send request
      await client.request(
        endpoint,
        queryParameters: {'pub': state.currentPublisher.value?.name},
        data: payload,
        options: Options(method: isNewPost ? 'POST' : 'PATCH'),
      );

      // Delete draft after successful submission
      if (state.postType == 1) {
        // Delete article draft
        await ref
            .read(composeStorageNotifierProvider.notifier)
            .deleteDraft(state.draftId);
      } else {
        // Delete regular post draft
        await ref
            .read(composeStorageNotifierProvider.notifier)
            .deleteDraft(state.draftId);
      }

      if (context.mounted) {
        Navigator.of(context).maybePop(true);
      }
    } catch (err) {
      showErrorAlert(err);
    } finally {
      state.submitting.value = false;
    }
  }

  static Future<void> handlePaste(ComposeState state) async {
    final clipboard = await Pasteboard.image;
    if (clipboard == null) return;

    state.attachments.value = [
      ...state.attachments.value,
      UniversalFile(
        data: XFile.fromData(clipboard, mimeType: "image/jpeg"),
        type: UniversalFileType.image,
      ),
    ];
  }

  static void handleKeyPress(
    KeyEvent event,
    ComposeState state,
    WidgetRef ref,
    BuildContext context, {
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
  }) {
    if (event is! KeyDownEvent) return;

    final isPaste = event.logicalKey == LogicalKeyboardKey.keyV;
    final isSave = event.logicalKey == LogicalKeyboardKey.keyS;
    final isModifierPressed =
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;
    final isSubmit = event.logicalKey == LogicalKeyboardKey.enter;

    if (isPaste && isModifierPressed) {
      handlePaste(state);
    } else if (isSave && isModifierPressed) {
      saveDraftManually(ref, state, context);
    } else if (isSubmit && isModifierPressed && !state.submitting.value) {
      performAction(
        ref,
        state,
        context,
        originalPost: originalPost,
        repliedPost: repliedPost,
        forwardedPost: forwardedPost,
      );
    }
  }

  static void dispose(ComposeState state) {
    state.stopAutoSave();
    state.titleController.dispose();
    state.descriptionController.dispose();
    state.contentController.dispose();
    state.attachments.dispose();
    state.visibility.dispose();
    state.submitting.dispose();
    state.attachmentProgress.dispose();
    state.currentPublisher.dispose();
    state.tagsController.dispose();
    state.categories.dispose();
    state.pollId.dispose();
  }
}
