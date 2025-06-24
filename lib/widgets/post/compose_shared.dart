import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/file.dart';
import 'package:island/services/compose_storage_db.dart';
import 'package:island/widgets/alert.dart';
import 'package:pasteboard/pasteboard.dart';
import 'dart:async';

class ComposeState {
  final ValueNotifier<List<UniversalFile>> attachments;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController contentController;
  final ValueNotifier<int> visibility;
  final ValueNotifier<bool> submitting;
  final ValueNotifier<Map<int, double>> attachmentProgress;
  final ValueNotifier<SnPublisher?> currentPublisher;
  final String draftId;
  Timer? _autoSaveTimer;

  ComposeState({
    required this.attachments,
    required this.titleController,
    required this.descriptionController,
    required this.contentController,
    required this.visibility,
    required this.submitting,
    required this.attachmentProgress,
    required this.currentPublisher,
    required this.draftId,
  });

  void startAutoSave(WidgetRef ref) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      ComposeLogic.saveDraft(ref, this);
    });
  }

  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }
}

class ComposeLogic {
  static ComposeState createState({
    SnPost? originalPost,
    SnPost? forwardedPost,
    SnPost? repliedPost,
    String? draftId,
  }) {
    final id = draftId ?? DateTime.now().millisecondsSinceEpoch.toString();

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
      contentController: TextEditingController(
        text:
            originalPost?.content ??
            (forwardedPost != null ? '> ${forwardedPost.content}\n\n' : null),
      ),
      visibility: ValueNotifier<int>(originalPost?.visibility ?? 0),
      submitting: ValueNotifier<bool>(false),
      attachmentProgress: ValueNotifier<Map<int, double>>({}),
      currentPublisher: ValueNotifier<SnPublisher?>(null),
      draftId: id,
    );
  }

  static ComposeState createStateFromDraft(ComposeDraftModel draft) {
    return ComposeState(
      attachments: ValueNotifier<List<UniversalFile>>([]),
      titleController: TextEditingController(text: draft.title),
      descriptionController: TextEditingController(text: draft.description),
      contentController: TextEditingController(text: draft.content),
      visibility: ValueNotifier<int>(_parseVisibility(draft.visibility)),
      submitting: ValueNotifier<bool>(false),
      attachmentProgress: ValueNotifier<Map<int, double>>({}),
      currentPublisher: ValueNotifier<SnPublisher?>(null),
      draftId: draft.id,
    );
  }

  static int _parseVisibility(String visibility) {
    switch (visibility.toLowerCase()) {
      case 'public':
        return 0;
      case 'unlisted':
        return 1;
      case 'friends':
        return 2;
      case 'selected':
        return 3;
      case 'private':
        return 4;
      default:
        return 0;
    }
  }

  static String _visibilityToString(int visibility) {
    switch (visibility) {
      case 0:
        return 'public';
      case 1:
        return 'unlisted';
      case 2:
        return 'friends';
      case 3:
        return 'selected';
      case 4:
        return 'private';
      default:
        return 'public';
    }
  }

  static Future<void> saveDraft(WidgetRef ref, ComposeState state) async {
    try {
      // Check if the auto-save timer is still active (widget not disposed)
      if (state._autoSaveTimer == null) {
        return; // Widget has been disposed, don't save
      }

      final draft = ComposeDraftModel(
        id: state.draftId,
        title: state.titleController.text,
        description: state.descriptionController.text,
        content: state.contentController.text,
        attachmentIds:
            state.attachments.value
                .where((e) => e.isOnCloud)
                .map((e) => e.data.id.toString())
                .toList(),
        visibility: _visibilityToString(state.visibility.value),
        lastModified: DateTime.now(),
      );

      await ref.read(composeStorageNotifierProvider.notifier).saveDraft(draft);
    } catch (e) {
      log('[ComposeLogic] Failed to save draft, error: $e');
      // Silently fail for auto-save to avoid disrupting user experience
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

  static Future<ComposeDraftModel?> loadDraft(WidgetRef ref, String draftId) async {
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
    if (attachment.isOnCloud) {
      final client = ref.watch(apiClientProvider);
      await client.delete('/files/${attachment.data.id}');
    }
    final clone = List.of(state.attachments.value);
    clone.removeAt(index);
    state.attachments.value = clone;
  }

  static Future<void> performAction(
    WidgetRef ref,
    ComposeState state,
    BuildContext context, {
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
    int? postType, // 0 for regular post, 1 for article
  }) async {
    if (state.submitting.value) return;

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
      final endpoint = isNewPost ? '/posts' : '/posts/${originalPost.id}';

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
        if (postType != null) 'type': postType,
        if (repliedPost != null) 'replied_post_id': repliedPost.id,
        if (forwardedPost != null) 'forwarded_post_id': forwardedPost.id,
      };

      // Send request
      await client.request(
        endpoint,
        data: payload,
        options: Options(
          headers: {'X-Pub': state.currentPublisher.value?.name},
          method: isNewPost ? 'POST' : 'PATCH',
        ),
      );

      // Delete draft after successful submission
      if (postType == 1) {
        // Delete article draft
        await ref
            .read(articleStorageNotifierProvider.notifier)
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
    RawKeyEvent event,
    ComposeState state,
    WidgetRef ref,
    BuildContext context, {
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
    int? postType,
  }) {
    if (event is! RawKeyDownEvent) return;

    final isPaste = event.logicalKey == LogicalKeyboardKey.keyV;
    final isSave = event.logicalKey == LogicalKeyboardKey.keyS;
    final isModifierPressed = event.isMetaPressed || event.isControlPressed;
    final isSubmit = event.logicalKey == LogicalKeyboardKey.enter;

    if (isPaste && isModifierPressed) {
      handlePaste(state);
    } else if (isSave && isModifierPressed) {
      saveDraft(ref, state);
    } else if (isSubmit && isModifierPressed && !state.submitting.value) {
      performAction(
        ref,
        state,
        context,
        originalPost: originalPost,
        repliedPost: repliedPost,
        forwardedPost: forwardedPost,
        postType: postType,
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
  }
}
