import 'dart:async';

import 'package:collection/collection.dart';
import 'package:island/core/config.dart';
import 'package:island/posts/widgets/compose/compose_calendar_event_sheet.dart';
import 'package:island/posts/widgets/compose/compose_fund.dart';
import 'package:island/posts/widgets/compose/compose_link_attachments.dart';
import 'package:island/posts/widgets/compose/compose_location_sheet.dart';
import 'package:island/posts/widgets/compose/compose_meet_sheet.dart';
import 'package:island/posts/widgets/compose/compose_survey.dart';
import 'package:island/posts/widgets/compose/compose_recorder.dart';
import 'package:island/posts/widgets/compose/compose_settings_sheet.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/core/database.dart';
import 'package:island/data/database.dart';
import 'package:island/core/network.dart';
import 'package:island/tasks/app_task.dart';
import 'package:island/tasks/tasks_notifier.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:island/drive/screens/file_pool.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:uuid/uuid.dart';

import 'package:island/core/services/analytics_service.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ComposeState {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController contentController;
  final TextEditingController slugController;
  final ValueNotifier<int> visibility;
  final ValueNotifier<String?> language;
  final ValueNotifier<List<UniversalFile>> attachments;
  final ValueNotifier<Map<int, double?>> attachmentProgress;
  final ValueNotifier<SnPublisher?> currentPublisher;
  final ValueNotifier<bool> submitting;
  final ValueNotifier<List<SnPostCategory>> categories;
  final ValueNotifier<List<String>> tags;
  final ValueNotifier<SnRealm?> realm;
  final ValueNotifier<SnPostEmbedView?> embedView;
  String draftId;
  final ValueNotifier<String?> cloudDraftId;
  int postType;

  // Unified embeds list (surveys, funds, meets, calendar events, locations, notable days)
  final ValueNotifier<List<Map<String, dynamic>>> embeds;

  // Thumbnail id for article type post (nullable)
  final ValueNotifier<String?> thumbnailId;
  // Collection IDs to assign the post to on creation
  final ValueNotifier<List<String>> collectionIds;
  Timer? _autoSaveTimer;

  ComposeState({
    required this.titleController,
    required this.descriptionController,
    required this.contentController,
    required this.slugController,
    required this.visibility,
    required this.language,
    required this.attachments,
    required this.attachmentProgress,
    required this.currentPublisher,
    required this.submitting,
    required this.tags,
    required this.categories,
    required this.realm,
    required this.embedView,
    required this.draftId,
    String? cloudDraftId,
    this.postType = 0,
    List<Map<String, dynamic>>? embeds,
    String? thumbnailId,
    List<String>? collectionIds,
  }) : embeds = ValueNotifier<List<Map<String, dynamic>>>(embeds ?? []),
       thumbnailId = ValueNotifier<String?>(thumbnailId),
       collectionIds = ValueNotifier<List<String>>(collectionIds ?? []),
       cloudDraftId = ValueNotifier<String?>(cloudDraftId);

  void startAutoSave(Future<void> Function(ComposeState state) saveDraft) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      saveDraft(this);
    });
  }

  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  bool get isEmpty =>
      attachments.value.isEmpty && contentController.text.isEmpty;
}

class ComposeSubmissionSnapshot {
  final String draftId;
  final String? cloudDraftId;
  final String title;
  final String description;
  final String content;
  final String slug;
  final int visibility;
  final String? language;
  final List<UniversalFile> attachments;
  final SnPublisher? publisher;
  final List<String> tags;
  final List<SnPostCategory> categories;
  final SnRealm? realm;
  final SnPostEmbedView? embedView;
  final int postType;
  final List<Map<String, dynamic>> embeds;
  final String? thumbnailId;
  final List<String> collectionIds;
  final String? originalPostId;
  final String? repliedPostId;
  final String? forwardedPostId;

  const ComposeSubmissionSnapshot({
    required this.draftId,
    required this.cloudDraftId,
    required this.title,
    required this.description,
    required this.content,
    required this.slug,
    required this.visibility,
    required this.language,
    required this.attachments,
    required this.publisher,
    required this.tags,
    required this.categories,
    required this.realm,
    required this.embedView,
    required this.postType,
    required this.embeds,
    required this.thumbnailId,
    required this.collectionIds,
    required this.originalPostId,
    required this.repliedPostId,
    required this.forwardedPostId,
  });

  String get activeDraftId => cloudDraftId ?? draftId;
}

class ComposeLogic {
  static String _taskDraftTitle(String title) {
    return title.trim().isNotEmpty ? title.trim() : 'taskPostPublishDraft'.tr();
  }

  static String _taskUploadingMessage(int attachmentCount) {
    return 'taskPostPublishUploading'.tr(
      namedArgs: {'count': attachmentCount.toString()},
    );
  }

  static String _taskUploadingProgressMessage(int current, int total) {
    return 'taskPostPublishUploadingProgress'.tr(
      namedArgs: {'current': current.toString(), 'total': total.toString()},
    );
  }

  static ComposeState createState({
    SnPost? originalPost,
    SnPost? forwardedPost,
    SnPost? repliedPost,
    String? draftId,
    String? cloudDraftId,
    int postType = 0,
  }) {
    final id = draftId ?? const Uuid().v4();

    // Initialize tags from original post
    final tags =
        originalPost?.tags.map((tag) => tag.slug).toList() ?? <String>[];

    // Initialize categories from original post
    final categories = originalPost?.categories ?? <SnPostCategory>[];

    // Extract embeds from original post meta
    final embeds = (originalPost?.meta?['embeds'] is List)
        ? (originalPost!.meta!['embeds'] as List)
              .cast<Map<String, dynamic>>()
              .toList()
        : <Map<String, dynamic>>[];

    // Extract thumbnail ID from meta
    final thumbnailId = originalPost?.meta?['thumbnail'] as String?;

    // Extract collection IDs from publisher collections
    final collectionIds =
        originalPost?.publisherCollections.map((c) => c.id).toList() ??
        <String>[];

    return ComposeState(
      attachments: ValueNotifier<List<UniversalFile>>(
        originalPost?.attachments
                .map(
                  (e) => UniversalFile(
                    data: e,
                    type: switch (e.mimeType.split('/').firstOrNull) {
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
      slugController: TextEditingController(text: originalPost?.slug),
      visibility: ValueNotifier<int>(originalPost?.visibility ?? 0),
      language: ValueNotifier<String?>(originalPost?.language),
      submitting: ValueNotifier<bool>(false),
      attachmentProgress: ValueNotifier<Map<int, double?>>({}),
      currentPublisher: ValueNotifier<SnPublisher?>(originalPost?.publisher),
      tags: ValueNotifier<List<String>>(tags),
      categories: ValueNotifier<List<SnPostCategory>>(categories),
      realm: ValueNotifier(originalPost?.realm),
      embedView: ValueNotifier<SnPostEmbedView?>(originalPost?.embedView),
      draftId: id,
      cloudDraftId:
          cloudDraftId ??
          (originalPost?.draftedAt != null ? originalPost?.id : null),
      postType: postType,
      embeds: embeds,
      thumbnailId: thumbnailId,
      collectionIds: collectionIds,
    );
  }

  static ComposeState createStateFromDraft(SnPost draft, {int postType = 0}) {
    final tags = draft.tags.map((tag) => tag.slug).toList();
    final thumbnailId = draft.meta?['thumbnail'] as String?;
    final collectionIds =
        (draft.meta?['collection_ids'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    // Extract embeds from draft meta
    final embeds = (draft.meta?['embeds'] is List)
        ? (draft.meta!['embeds'] as List).cast<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    return ComposeState(
      attachments: ValueNotifier<List<UniversalFile>>(
        draft.attachments.map((e) => UniversalFile.fromAttachment(e)).toList(),
      ),
      titleController: TextEditingController(text: draft.title),
      descriptionController: TextEditingController(text: draft.description),
      contentController: TextEditingController(text: draft.content),
      slugController: TextEditingController(text: draft.slug),
      visibility: ValueNotifier<int>(draft.visibility),
      language: ValueNotifier<String?>(draft.language),
      submitting: ValueNotifier<bool>(false),
      attachmentProgress: ValueNotifier<Map<int, double?>>({}),
      currentPublisher: ValueNotifier<SnPublisher?>(null),
      tags: ValueNotifier<List<String>>(tags),
      categories: ValueNotifier<List<SnPostCategory>>(draft.categories),
      realm: ValueNotifier(draft.realm),
      embedView: ValueNotifier<SnPostEmbedView?>(draft.embedView),
      draftId: draft.id,
      cloudDraftId: draft.draftedAt != null ? draft.id : null,
      postType: postType,
      embeds: embeds,
      thumbnailId: thumbnailId,
      collectionIds: collectionIds,
    );
  }

  static void applyDraftToState(ComposeState state, SnPost draft) {
    state.draftId = draft.id;
    state.cloudDraftId.value = draft.draftedAt != null ? draft.id : null;
    state.titleController.text = draft.title ?? '';
    state.descriptionController.text = draft.description ?? '';
    state.contentController.text = draft.content ?? '';
    state.slugController.text = draft.slug ?? '';
    state.visibility.value = draft.visibility;
    state.language.value = draft.language;
    state.attachments.value = draft.attachments
        .map((e) => UniversalFile.fromAttachment(e))
        .toList();
    state.tags.value = draft.tags.map((tag) => tag.slug).toList();
    state.categories.value = draft.categories;
    state.realm.value = draft.realm;
    state.embedView.value = draft.embedView;
    state.embeds.value =
        (draft.meta?['embeds'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        <Map<String, dynamic>>[];
    state.thumbnailId.value = draft.meta?['thumbnail'] as String?;
    state.collectionIds.value =
        (draft.meta?['collection_ids'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];
  }

  static ComposeSubmissionSnapshot createSubmissionSnapshot(
    ComposeState state, {
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
  }) {
    return ComposeSubmissionSnapshot(
      draftId: state.draftId,
      cloudDraftId: state.cloudDraftId.value,
      title: state.titleController.text,
      description: state.descriptionController.text,
      content: state.contentController.text,
      slug: state.slugController.text,
      visibility: state.visibility.value,
      language: state.language.value,
      attachments: List<UniversalFile>.from(state.attachments.value),
      publisher: state.currentPublisher.value,
      tags: List<String>.from(state.tags.value),
      categories: List<SnPostCategory>.from(state.categories.value),
      realm: state.realm.value,
      embedView: state.embedView.value,
      postType: state.postType,
      embeds: state.embeds.value
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      thumbnailId: state.thumbnailId.value,
      collectionIds: List<String>.from(state.collectionIds.value),
      originalPostId: originalPost?.id,
      repliedPostId: repliedPost?.id,
      forwardedPostId: forwardedPost?.id,
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
      // Upload any local attachments first
      for (int i = 0; i < state.attachments.value.length; i++) {
        final attachment = state.attachments.value[i];
        if (attachment.data is! SnCloudFile) {
          try {
            final cloudFile = await ref
                .read(driveFileUploaderProvider)
                .createCloudFile(fileData: attachment, usage: 'post')
                .future;
            if (cloudFile != null) {
              // Update attachments list with cloud file
              final clone = List.of(state.attachments.value);
              clone[i] = UniversalFile(data: cloudFile, type: attachment.type);
              state.attachments.value = clone;
            }
          } catch (err) {
            Logger.root.severe(
              '[ComposeLogic] Failed to upload attachment: $err',
            );
            // Continue with other attachments even if one fails
          }
        }
      }

      await _saveLocalDraft(ref.read(databaseProvider), state);
      if (state.cloudDraftId.value != null) {
        await _saveCloudDraft(ref, state);
      }
    } catch (e) {
      Logger.root.severe('[ComposeLogic] Failed to save draft, error: $e');
    }
  }

  static Future<void> saveDraftWithoutUpload(
    WidgetRef ref,
    ComposeState state,
  ) async {
    final database = ref.read(databaseProvider);
    return saveDraftWithoutUploadWithDatabase(database, state);
  }

  static Future<void> saveDraftWithoutUploadWithDatabase(
    AppDatabase database,
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
      await _saveLocalDraft(database, state);
    } catch (e) {
      Logger.root.severe(
        '[ComposeLogic] Failed to save draft without upload, error: $e',
      );
    }
  }

  static Future<void> _saveLocalDraft(
    AppDatabase database,
    ComposeState state,
  ) async {
    final localId = state.cloudDraftId.value ?? state.draftId;
    final meta = <String, dynamic>{
      if (state.postType == 1 && state.thumbnailId.value != null)
        'thumbnail': state.thumbnailId.value,
      if (state.collectionIds.value.isNotEmpty)
        'collection_ids': state.collectionIds.value,
      if (state.embeds.value.isNotEmpty) 'embeds': state.embeds.value,
    };
    final draft = SnPost(
      id: localId,
      title: state.titleController.text,
      description: state.descriptionController.text,
      language: state.language.value,
      editedAt: null,
      draftedAt: state.cloudDraftId.value != null ? DateTime.now() : null,
      publishedAt: null,
      visibility: state.visibility.value,
      content: state.contentController.text,
      slug: state.slugController.text,
      type: state.postType,
      meta: meta.isEmpty ? null : meta,
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
      realmId: state.realm.value?.id,
      realm: state.realm.value,
      attachments: state.attachments.value
          .map((e) => e.data)
          .whereType<SnCloudFileReference>()
          .toList(),
      publisher: SnPublisher(
        id: state.currentPublisher.value?.id ?? '',
        type: state.currentPublisher.value?.type ?? 0,
        name: state.currentPublisher.value?.name ?? '',
        nick: state.currentPublisher.value?.nick ?? '',
        realmNick: state.currentPublisher.value?.realmNick,
        picture: state.currentPublisher.value?.picture,
        background: state.currentPublisher.value?.background,
        account: state.currentPublisher.value?.account,
        accountId: state.currentPublisher.value?.accountId,
        createdAt: state.currentPublisher.value?.createdAt ?? DateTime.now(),
        updatedAt: state.currentPublisher.value?.updatedAt ?? DateTime.now(),
        deletedAt: state.currentPublisher.value?.deletedAt,
        realmId: state.currentPublisher.value?.realmId,
        realmBio: state.currentPublisher.value?.realmBio,
        realmExperience: state.currentPublisher.value?.realmExperience,
        realmLevel: state.currentPublisher.value?.realmLevel,
        realmLevelingProgress:
            state.currentPublisher.value?.realmLevelingProgress,
        realmLabel: state.currentPublisher.value?.realmLabel,
        verification: state.currentPublisher.value?.verification,
      ),
      reactions: [],
      tags: state.tags.value
          .map(
            (tag) => SnPostTag(
              id: tag,
              slug: tag,
              name: tag,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
          .toList(),
      categories: state.categories.value,
      collections: [],
      embedView: state.embedView.value,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null,
    );
    await database.addPostDraftFromPost(
      draft.copyWith(updatedAt: draft.updatedAt ?? DateTime.now()),
    );
  }

  static Future<void> _saveLocalDraftSnapshot(
    ComposeSubmissionSnapshot snapshot, {
    required List<UniversalFile> attachments,
    required Future<void> Function(SnPost draft) saveDraft,
    String? cloudDraftId,
  }) async {
    final localId = cloudDraftId ?? snapshot.draftId;
    final meta = <String, dynamic>{
      if (snapshot.postType == 1 && snapshot.thumbnailId != null)
        'thumbnail': snapshot.thumbnailId,
      if (snapshot.collectionIds.isNotEmpty)
        'collection_ids': snapshot.collectionIds,
      if (snapshot.embeds.isNotEmpty) 'embeds': snapshot.embeds,
    };
    final draft = SnPost(
      id: localId,
      title: snapshot.title,
      description: snapshot.description,
      language: snapshot.language,
      editedAt: null,
      draftedAt: cloudDraftId != null ? DateTime.now() : null,
      publishedAt: null,
      visibility: snapshot.visibility,
      content: snapshot.content,
      slug: snapshot.slug,
      type: snapshot.postType,
      meta: meta.isEmpty ? null : meta,
      viewsUnique: 0,
      viewsTotal: 0,
      upvotes: 0,
      downvotes: 0,
      repliesCount: 0,
      threadedPostId: null,
      threadedPost: null,
      repliedPostId: snapshot.repliedPostId,
      repliedPost: null,
      forwardedPostId: snapshot.forwardedPostId,
      forwardedPost: null,
      realmId: snapshot.realm?.id,
      realm: snapshot.realm,
      attachments: attachments
          .map((e) => e.data)
          .whereType<SnCloudFileReference>()
          .toList(),
      publisher: snapshot.publisher,
      reactions: [],
      tags: snapshot.tags
          .map(
            (tag) => SnPostTag(
              id: tag,
              slug: tag,
              name: tag,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
          .toList(),
      categories: snapshot.categories,
      collections: [],
      embedView: snapshot.embedView,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null,
    );
    await saveDraft(draft);
  }

  static Future<void> _saveCloudDraft(WidgetRef ref, ComposeState state) async {
    final publisherName = state.currentPublisher.value?.name;
    if (publisherName == null || publisherName.isEmpty) return;

    final client = ref.read(solarNetworkClientProvider);
    final endpoint = state.cloudDraftId.value == null
        ? '/sphere/posts'
        : '/sphere/posts/${state.cloudDraftId.value}';
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = {
      'title': state.titleController.text,
      'description': state.descriptionController.text,
      'content': state.contentController.text,
      if (state.slugController.text.isNotEmpty)
        'slug': state.slugController.text,
      'visibility': state.visibility.value,
      'attachments': state.attachments.value
          .where((e) => e.isOnCloud)
          .map((e) => e.data.id)
          .toList(),
      'type': state.postType,
      'tags': state.tags.value,
      'categories': state.categories.value.map((e) => e.slug).toList(),
      if (state.realm.value != null) 'realm_id': state.realm.value?.id,
      if (state.embeds.value.isNotEmpty) 'embeds': state.embeds.value,
      if (state.postType == 1 && state.thumbnailId.value != null)
        'thumbnail_id': state.thumbnailId.value,
      if (state.embedView.value != null)
        'embed_view': state.embedView.value!.toJson(),
      if (state.collectionIds.value.isNotEmpty)
        'collection_ids': state.collectionIds.value,
      'drafted_at': now,
      'published_at': null,
    };

    // Use raw Dio call since we need custom endpoint and query parameters
    final response = await client.dio.request(
      endpoint,
      queryParameters: {'pub': publisherName},
      data: payload,
      options: Options(
        method: state.cloudDraftId.value == null ? 'POST' : 'PATCH',
      ),
    );
    final previousDraftId = state.draftId;
    final post = SnPost.fromJson(response.data);
    state.cloudDraftId.value = post.id;
    state.draftId = post.id;
    await ref.read(composeStorageProvider.notifier).saveDraft(post);
    if (previousDraftId != post.id) {
      await ref
          .read(composeStorageProvider.notifier)
          .deleteLocalDraft(previousDraftId);
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
      Logger.root.severe(
        '[ComposeLogic] Failed to save draft manually, error: $e',
      );
      if (context.mounted) {
        showSnackBar('draftSaveFailed'.tr());
      }
    }
  }

  static Future<void> deleteDraft(WidgetRef ref, String draftId) async {
    try {
      await ref.read(composeStorageProvider.notifier).deleteDraft(draftId);
    } catch (e) {
      // Silently fail
    }
  }

  static Future<SnPost?> loadDraft(WidgetRef ref, String draftId) async {
    try {
      return ref.read(composeStorageProvider.notifier).getDraft(draftId);
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

  static Future<void> pickGeneralFile(WidgetRef ref, ComposeState state) async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null || result.count == 0) return;

    final newFiles = <UniversalFile>[];

    for (final f in result.files) {
      if (f.path == null) continue;

      final mimeType =
          lookupMimeType(f.path!, headerBytes: f.bytes) ??
          'application/octet-stream';
      final xfile = XFile(f.path!, name: f.name, mimeType: mimeType);

      final uf = UniversalFile(data: xfile, type: UniversalFileType.file);
      newFiles.add(uf);
    }

    state.attachments.value = [...state.attachments.value, ...newFiles];
  }

  static Future<void> pickPhotoMedia(WidgetRef ref, ComposeState state) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> results = await picker.pickMultiImage();
    if (results.isEmpty) return;
    state.attachments.value = [
      ...state.attachments.value,
      ...results.map(
        (xfile) => UniversalFile(data: xfile, type: UniversalFileType.image),
      ),
    ];
  }

  static Future<void> pickVideoMedia(WidgetRef ref, ComposeState state) async {
    final result = await FilePicker.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result == null || result.count == 0) return;
    state.attachments.value = [
      ...state.attachments.value,
      ...result.files.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.video),
      ),
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
    final result = await showModalBottomSheet<Object?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const ComposeLinkAttachment(allowMultiSelect: true),
    );
    if (result == null) return;

    final cloudFiles = result is SnCloudFile
        ? [result]
        : result is List
        ? result.whereType<SnCloudFile>().toList(growable: false)
        : const <SnCloudFile>[];
    if (cloudFiles.isEmpty) return;

    final existingCloudIds = state.attachments.value
        .where((item) => item.isOnCloud)
        .map((item) => item.data.id)
        .toSet();

    final linkedAttachments = <UniversalFile>[];
    for (final cloudFile in cloudFiles) {
      if (!existingCloudIds.add(cloudFile.id)) continue;
      linkedAttachments.add(
        UniversalFile(
          data: cloudFile,
          type: switch (cloudFile.mimeType.split('/').firstOrNull) {
            'image' => UniversalFileType.image,
            'video' => UniversalFileType.video,
            'audio' => UniversalFileType.audio,
            _ => UniversalFileType.file,
          },
          isLink: true,
        ),
      );
    }
    if (linkedAttachments.isEmpty) return;

    state.attachments.value = [
      ...state.attachments.value,
      ...linkedAttachments,
    ];
  }

  static void updateAttachment(
    ComposeState state,
    UniversalFile value,
    int index,
  ) {
    state.attachments.value = state.attachments.value.mapIndexed((idx, ele) {
      if (idx == index) return value;
      return ele;
    }).toList();
  }

  static Future<void> uploadAttachment(
    WidgetRef ref,
    ComposeState state,
    int index, {
    String? poolId,
  }) async {
    final attachment = state.attachments.value[index];
    if (attachment.isOnCloud) return;

    try {
      state.attachmentProgress.value = {
        ...state.attachmentProgress.value,
        index: 0.0,
      };

      SnCloudFile? cloudFile;

      final pools = await ref.read(poolsProvider.future);
      final selectedPoolId = resolveDefaultPoolId(
        ref.read(appSettingsProvider),
        pools,
      );

      cloudFile = await ref
          .read(driveFileUploaderProvider)
          .createCloudFile(
            fileData: attachment,
            poolId: poolId ?? selectedPoolId,
            usage: 'post',
            mode: attachment.type == UniversalFileType.file
                ? FileUploadMode.generic
                : FileUploadMode.mediaSafe,
            onProgress: (progress, _) {
              state.attachmentProgress.value = {
                ...state.attachmentProgress.value,
                index: progress ?? 0.0,
              };
            },
          )
          .future;

      if (cloudFile == null) {
        throw ArgumentError('Failed to upload the file...');
      }

      final clone = List.of(state.attachments.value);
      clone[index] = UniversalFile(data: cloudFile, type: attachment.type);
      state.attachments.value = clone;
    } catch (err) {
      showErrorAlert(err);
    } finally {
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
      final client = ref.watch(solarNetworkClientProvider);
      try {
        await client.drive.deleteFile(attachment.data.id);
      } catch (e) {
        // Silently fail, we will attempt to delete the cloud file again on upload if it still exists
      }
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

  static void setEmbedView(ComposeState state, SnPostEmbedView embedView) {
    state.embedView.value = embedView;
  }

  static void updateEmbedView(ComposeState state, SnPostEmbedView embedView) {
    state.embedView.value = embedView;
  }

  static void deleteEmbedView(ComposeState state) {
    state.embedView.value = null;
  }

  // --- Embed helpers for the unified embeds list ---

  static bool hasEmbed(ComposeState state, String type) {
    return state.embeds.value.any((e) => e['type'] == type);
  }

  static void addEmbed(ComposeState state, Map<String, dynamic> embed) {
    state.embeds.value = [...state.embeds.value, embed];
  }

  static void removeEmbed(ComposeState state, String type) {
    state.embeds.value = state.embeds.value
        .where((e) => e['type'] != type)
        .toList();
  }

  static void updateEmbed(
    ComposeState state,
    String type,
    Map<String, dynamic> embed,
  ) {
    state.embeds.value = [
      for (final e in state.embeds.value)
        if (e['type'] == type) embed else e,
    ];
  }

  static void setThumbnail(ComposeState state, String? thumbnailId) {
    state.thumbnailId.value = thumbnailId;
  }

  static Future<void> pickSurvey(
    WidgetRef ref,
    ComposeState state,
    BuildContext context,
  ) async {
    if (hasEmbed(state, 'survey')) {
      removeEmbed(state, 'survey');
      return;
    }

    final survey = await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) =>
          ComposeSurveySheet(pub: state.currentPublisher.value),
    );

    if (survey == null) return;
    addEmbed(state, {'type': 'survey', 'id': survey.id});
  }

  static Future<void> pickFund(
    WidgetRef ref,
    ComposeState state,
    BuildContext context,
  ) async {
    if (hasEmbed(state, 'fund')) {
      removeEmbed(state, 'fund');
      return;
    }

    final fund = await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const ComposeFundSheet(),
    );

    if (fund == null) return;
    addEmbed(state, {'type': 'fund', 'id': fund.id});
  }

  static Future<void> pickLocation(
    WidgetRef ref,
    ComposeState state,
    BuildContext context,
  ) async {
    if (hasEmbed(state, 'location')) {
      removeEmbed(state, 'location');
      return;
    }

    final location = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const ComposeLocationSheet(),
    );

    if (location == null) return;
    addEmbed(state, {
      'type': 'location',
      if (location['name'] != null) 'name': location['name'],
      if (location['address'] != null) 'address': location['address'],
      if (location['wkt'] != null) 'wkt': location['wkt'],
    });
  }

  static Future<void> pickMeet(
    WidgetRef ref,
    ComposeState state,
    BuildContext context,
  ) async {
    if (hasEmbed(state, 'meet')) {
      removeEmbed(state, 'meet');
      return;
    }

    final meet = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const ComposeMeetSheet(),
    );

    if (meet == null) return;
    addEmbed(state, {'type': 'meet', 'id': meet});
  }

  static Future<void> pickCalendarEvent(
    WidgetRef ref,
    ComposeState state,
    BuildContext context,
  ) async {
    if (hasEmbed(state, 'calendar_event')) {
      removeEmbed(state, 'calendar_event');
      return;
    }

    final event = await showModalBottomSheet<SnUserCalendarEvent>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const ComposeCalendarEventSheet(),
    );

    if (event == null) return;
    addEmbed(state, {'type': 'calendar_event', 'id': event.id});
  }

  /// Unified submit method that returns the created/updated post.
  static Future<SnPost> performSubmit(
    WidgetRef ref,
    ComposeState state,
    BuildContext context, {
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
    required Function() onSuccess,
  }) async {
    if (state.submitting.value) {
      throw Exception('Already submitting');
    }

    // Don't submit empty posts (no content and no attachments)
    final hasContent =
        state.titleController.text.trim().isNotEmpty ||
        state.descriptionController.text.trim().isNotEmpty ||
        state.contentController.text.trim().isNotEmpty;
    final hasAttachments = state.attachments.value.isNotEmpty;

    if (!hasContent && !hasAttachments) {
      showErrorAlert('postContentEmpty'.tr());
      throw Exception('Post content is empty'); // Don't submit empty posts
    }

    try {
      state.submitting.value = true;

      final localAttachments = state.attachments.value
          .asMap()
          .entries
          .where((entry) => entry.value.isOnDevice)
          .toList();

      // Create a task for tracking
      final tasks = ref.read(tasksProvider.notifier);
      final taskId = tasks.addTask(
        title: _taskDraftTitle(state.titleController.text),
        type: AppTaskType.postPublish,
        status: AppTaskStatus.inProgress,
        metadata: PostPublishTaskMeta(
          draftId: state.cloudDraftId.value,
          attachmentCount: localAttachments.length,
        ).toMap(),
      );

      // Upload any local attachments first
      if (localAttachments.isNotEmpty) {
        tasks.updateTask(
          taskId,
          progress: 0.1,
          statusMessage: _taskUploadingMessage(localAttachments.length),
        );
        await Future.wait(
          localAttachments.map(
            (entry) => ComposeLogic.uploadAttachment(ref, state, entry.key),
          ),
        );
      }

      tasks.updateTask(
        taskId,
        progress: 0.6,
        statusMessage: 'taskPostPublishPublishing'.tr(),
      );

      final client = ref.read(solarNetworkClientProvider);
      final isNewPost = originalPost == null;
      final endpoint =
          '/sphere${isNewPost ? '/posts' : '/posts/${originalPost.id}'}';

      // Create request payload
      final payload = {
        'title': state.titleController.text,
        'description': state.descriptionController.text,
        'content': state.contentController.text,
        'language': state.language.value,
        if (state.slugController.text.isNotEmpty)
          'slug': state.slugController.text,
        'visibility': state.visibility.value,
        'attachments': state.attachments.value
            .where((e) => e.isOnCloud)
            .map((e) => e.data.id)
            .toList(),
        'type': state.postType,
        if (repliedPost != null) 'replied_post_id': repliedPost.id,
        if (forwardedPost != null) 'forwarded_post_id': forwardedPost.id,
        'tags': state.tags.value,
        'categories': state.categories.value.map((e) => e.slug).toList(),
        if (state.realm.value != null) 'realm_id': state.realm.value?.id,
        if (state.embeds.value.isNotEmpty) 'embeds': state.embeds.value,
        if (state.postType == 1 && state.thumbnailId.value != null)
          'thumbnail_id': state.thumbnailId.value,
        if (state.embedView.value != null)
          'embed_view': state.embedView.value!.toJson(),
        if (state.collectionIds.value.isNotEmpty)
          'collection_ids': state.collectionIds.value,
      };

      // Run plugin hooks before publishing
      final hookResult = PluginHooks().runBeforePostCreate(
        Map<String, dynamic>.from(payload),
      );
      if (hookResult.cancelled) {
        showSnackBar('Post blocked by plugin: ${hookResult.cancelledBy}');
        state.submitting.value = false;
        throw Exception('Post blocked by plugin');
      }
      final effectivePayload = hookResult.data ?? payload;

      final publisherName = state.currentPublisher.value?.name;
      if (publisherName == null || publisherName.isEmpty) {
        throw Exception('Publisher is required');
      }

      late final SnPost post;

      // Publish server-side draft directly when available.
      if (isNewPost && state.cloudDraftId.value != null) {
        await client.dio.request(
          '/sphere/posts/${state.cloudDraftId.value}',
          queryParameters: {'pub': publisherName},
          data: {
            ...effectivePayload,
            'drafted_at': DateTime.now().toUtc().toIso8601String(),
            'published_at': null,
          },
          options: Options(method: 'PATCH'),
        );
        final publishResp = await client.dio.post(
          '/sphere/posts/${state.cloudDraftId.value}/publish',
          queryParameters: {'pub': publisherName},
        );
        post = SnPost.fromJson(publishResp.data);
      } else {
        final response = await client.dio.request(
          endpoint,
          queryParameters: {'pub': publisherName},
          data: effectivePayload,
          options: Options(method: isNewPost ? 'POST' : 'PATCH'),
        );
        post = SnPost.fromJson(response.data);
      }

      // Call the success callback
      onSuccess();

      tasks.updateTask(
        taskId,
        status: AppTaskStatus.completed,
        progress: 1.0,
        statusMessage: 'taskPostPublishPublished'.tr(),
      );

      final postTypeStr = state.postType == 0
          ? 'regular'
          : state.postType == 1
          ? 'article'
          : 'blog';
      final visibilityStr = state.visibility.value.toString();
      final publisherId = state.currentPublisher.value?.id ?? 'unknown';

      AnalyticsService().logPostCreated(
        postTypeStr,
        visibilityStr,
        state.attachments.value.isNotEmpty,
        publisherId,
      );

      return post;
    } catch (err) {
      // Mark task as failed if it was created
      final existingTask = ref
          .read(tasksProvider)
          .where(
            (t) =>
                t.type == AppTaskType.postPublish &&
                t.status == AppTaskStatus.inProgress,
          )
          .lastOrNull;
      if (existingTask != null) {
        ref
            .read(tasksProvider.notifier)
            .updateTask(
              existingTask.id,
              status: AppTaskStatus.failed,
              errorMessage: err.toString(),
            );
      }
      showErrorAlert(err);
      rethrow;
    } finally {
      state.submitting.value = false;
    }
  }

  static Future<void> submitInBackground(
    WidgetRef ref,
    ComposeState state, {
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
    required VoidCallback onSubmitted,
    VoidCallback? onSuccess,
  }) async {
    if (state.submitting.value) {
      throw Exception('Already submitting');
    }

    final hasContent =
        state.titleController.text.trim().isNotEmpty ||
        state.descriptionController.text.trim().isNotEmpty ||
        state.contentController.text.trim().isNotEmpty;
    final hasAttachments = state.attachments.value.isNotEmpty;

    if (!hasContent && !hasAttachments) {
      showErrorAlert('postContentEmpty'.tr());
      throw Exception('Post content is empty');
    }

    final publisherName = state.currentPublisher.value?.name;
    if (publisherName == null || publisherName.isEmpty) {
      showErrorAlert('Publisher is required');
      throw Exception('Publisher is required');
    }

    state.submitting.value = true;

    try {
      await saveDraftWithoutUpload(ref, state);

      final snapshot = createSubmissionSnapshot(
        state,
        originalPost: originalPost,
        repliedPost: repliedPost,
        forwardedPost: forwardedPost,
      );
      final tasks = ref.read(tasksProvider.notifier);
      final database = ref.read(databaseProvider);
      final client = ref.read(solarNetworkClientProvider);
      final uploader = ref.read(driveFileUploaderProvider);
      final pools = await ref.read(poolsProvider.future);
      final selectedPoolId = resolveDefaultPoolId(
        ref.read(appSettingsProvider),
        pools,
      );
      final localAttachments = snapshot.attachments
          .where((attachment) => attachment.isOnDevice)
          .length;

      final taskId = tasks.addTask(
        title: _taskDraftTitle(snapshot.title),
        type: AppTaskType.postPublish,
        status: AppTaskStatus.inProgress,
        metadata: PostPublishTaskMeta(
          draftId: snapshot.activeDraftId,
          attachmentCount: localAttachments,
        ).toMap(),
      );

      onSubmitted();

      unawaited(
        _runBackgroundSubmit(
          snapshot,
          taskId,
          tasks: tasks,
          saveDraft: (draft) async {
            await database.addPostDraftFromPost(
              draft.copyWith(updatedAt: draft.updatedAt ?? DateTime.now()),
            );
          },
          deleteLocalDraft: database.deletePostDraft,
          client: client,
          uploader: uploader,
          selectedPoolId: selectedPoolId,
          onSuccess: onSuccess,
        ),
      );
    } catch (_) {
      state.submitting.value = false;
      rethrow;
    }
  }

  static Future<UniversalFile> _uploadAttachmentForSnapshot(
    FileUploader uploader,
    UniversalFile attachment, {
    required String? selectedPoolId,
    required void Function(double progress) onProgress,
  }) async {
    if (attachment.isOnCloud) return attachment;

    final cloudFile = await uploader
        .createCloudFile(
          fileData: attachment,
          poolId: selectedPoolId,
          usage: 'post',
          mode: attachment.type == UniversalFileType.file
              ? FileUploadMode.generic
              : FileUploadMode.mediaSafe,
          onProgress: (progress, _) => onProgress(progress ?? 0.0),
        )
        .future;

    if (cloudFile == null) {
      throw ArgumentError('Failed to upload the file...');
    }

    return UniversalFile(data: cloudFile, type: attachment.type);
  }

  static Future<void> _runBackgroundSubmit(
    ComposeSubmissionSnapshot snapshot,
    String taskId, {
    required Tasks tasks,
    required Future<void> Function(SnPost draft) saveDraft,
    required Future<void> Function(String draftId) deleteLocalDraft,
    required dynamic client,
    required FileUploader uploader,
    required String? selectedPoolId,
    VoidCallback? onSuccess,
  }) async {
    var cloudDraftId = snapshot.cloudDraftId;
    var attachments = List<UniversalFile>.from(snapshot.attachments);

    try {
      final localAttachmentIndexes = attachments
          .asMap()
          .entries
          .where((entry) => entry.value.isOnDevice)
          .map((entry) => entry.key)
          .toList();

      if (localAttachmentIndexes.isNotEmpty) {
        tasks.updateTask(
          taskId,
          progress: 0.1,
          statusMessage: _taskUploadingMessage(localAttachmentIndexes.length),
        );

        for (var i = 0; i < localAttachmentIndexes.length; i++) {
          final index = localAttachmentIndexes[i];
          attachments[index] = await _uploadAttachmentForSnapshot(
            uploader,
            attachments[index],
            selectedPoolId: selectedPoolId,
            onProgress: (progress) {
              final base = i / localAttachmentIndexes.length;
              final step = progress / localAttachmentIndexes.length;
              tasks.updateTask(
                taskId,
                progress: 0.1 + ((base + step) * 0.5),
                statusMessage: _taskUploadingProgressMessage(
                  i + 1,
                  localAttachmentIndexes.length,
                ),
              );
            },
          );
          await _saveLocalDraftSnapshot(
            snapshot,
            attachments: attachments,
            saveDraft: saveDraft,
            cloudDraftId: cloudDraftId,
          );
        }
      } else {
        await _saveLocalDraftSnapshot(
          snapshot,
          attachments: attachments,
          saveDraft: saveDraft,
          cloudDraftId: cloudDraftId,
        );
      }

      tasks.updateTask(
        taskId,
        progress: 0.65,
        statusMessage: 'taskPostPublishPublishing'.tr(),
      );

      final payload = {
        'title': snapshot.title,
        'description': snapshot.description,
        'content': snapshot.content,
        'language': snapshot.language,
        if (snapshot.slug.isNotEmpty) 'slug': snapshot.slug,
        'visibility': snapshot.visibility,
        'attachments': attachments
            .where((e) => e.isOnCloud)
            .map((e) => e.data.id)
            .toList(),
        'type': snapshot.postType,
        if (snapshot.repliedPostId != null)
          'replied_post_id': snapshot.repliedPostId,
        if (snapshot.forwardedPostId != null)
          'forwarded_post_id': snapshot.forwardedPostId,
        'tags': snapshot.tags,
        'categories': snapshot.categories.map((e) => e.slug).toList(),
        if (snapshot.realm != null) 'realm_id': snapshot.realm?.id,
        if (snapshot.embeds.isNotEmpty) 'embeds': snapshot.embeds,
        if (snapshot.postType == 1 && snapshot.thumbnailId != null)
          'thumbnail_id': snapshot.thumbnailId,
        if (snapshot.embedView != null)
          'embed_view': snapshot.embedView!.toJson(),
        if (snapshot.collectionIds.isNotEmpty)
          'collection_ids': snapshot.collectionIds,
      };

      final hookResult = PluginHooks().runBeforePostCreate(
        Map<String, dynamic>.from(payload),
      );
      if (hookResult.cancelled) {
        throw Exception('Post blocked by plugin: ${hookResult.cancelledBy}');
      }
      final effectivePayload = hookResult.data ?? payload;

      final publisherName = snapshot.publisher?.name;
      if (publisherName == null || publisherName.isEmpty) {
        throw Exception('Publisher is required');
      }

      late final SnPost post;
      final isNewPost = snapshot.originalPostId == null;
      if (isNewPost && cloudDraftId != null) {
        await client.dio.request(
          '/sphere/posts/$cloudDraftId',
          queryParameters: {'pub': publisherName},
          data: {
            ...effectivePayload,
            'drafted_at': DateTime.now().toUtc().toIso8601String(),
            'published_at': null,
          },
          options: Options(method: 'PATCH'),
        );
        final publishResp = await client.dio.post(
          '/sphere/posts/$cloudDraftId/publish',
          queryParameters: {'pub': publisherName},
        );
        post = SnPost.fromJson(publishResp.data);
      } else {
        final endpoint =
            '/sphere${isNewPost ? '/posts' : '/posts/${snapshot.originalPostId}'}';
        final response = await client.dio.request(
          endpoint,
          queryParameters: {'pub': publisherName},
          data: effectivePayload,
          options: Options(method: isNewPost ? 'POST' : 'PATCH'),
        );
        post = SnPost.fromJson(response.data);
      }

      final draftIds = <String>{
        snapshot.draftId,
        ...?snapshot.cloudDraftId == null ? null : {snapshot.cloudDraftId!},
        ...?cloudDraftId == null ? null : {cloudDraftId},
      };
      for (final id in draftIds) {
        await deleteLocalDraft(id);
      }

      tasks.updateTask(
        taskId,
        status: AppTaskStatus.completed,
        progress: 1.0,
        statusMessage: 'taskPostPublishPublished'.tr(),
        result: {'postId': post.id},
      );

      final postTypeStr = snapshot.postType == 0
          ? 'regular'
          : snapshot.postType == 1
          ? 'article'
          : 'blog';
      AnalyticsService().logPostCreated(
        postTypeStr,
        snapshot.visibility.toString(),
        attachments.isNotEmpty,
        snapshot.publisher?.id ?? 'unknown',
      );

      onSuccess?.call();
    } catch (err) {
      await _saveLocalDraftSnapshot(
        snapshot,
        attachments: attachments,
        saveDraft: saveDraft,
        cloudDraftId: cloudDraftId,
      );
      tasks.updateTask(
        taskId,
        status: AppTaskStatus.failed,
        errorMessage: err.toString(),
        metadata: PostPublishTaskMeta(
          draftId: cloudDraftId ?? snapshot.draftId,
          attachmentCount: attachments.where((e) => e.isOnDevice).length,
        ).toMap(),
      );
    }
  }

  static Future<void> performAction(
    WidgetRef ref,
    ComposeState state,
    BuildContext context, {
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
  }) async {
    await ComposeLogic.performSubmit(
      ref,
      state,
      context,
      originalPost: originalPost,
      repliedPost: repliedPost,
      forwardedPost: forwardedPost,
      onSuccess: () async {
        // Delete draft after successful submission
        final storage = ref.read(composeStorageProvider.notifier);
        final toDelete = <String>{
          state.draftId,
          if (state.cloudDraftId.value != null) state.cloudDraftId.value!,
        };
        for (final id in toDelete) {
          await storage.deleteLocalDraft(id);
        }

        if (context.mounted) {
          Navigator.of(context).maybePop(true);
        }
      },
    );
  }

  /// Shows the settings sheet modal.
  static void showSettingsSheet(BuildContext context, ComposeState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ComposeSettingsSheet(state: state),
    );
  }

  static Future<void> handlePaste(ComposeState state) async {
    final clipboard = await Pasteboard.image;
    if (clipboard == null) return;

    state.attachments.value = [
      ...state.attachments.value,
      UniversalFile(
        displayName: 'image.jpeg',
        data: XFile.fromData(
          clipboard,
          mimeType: "image/jpeg",
          name: 'image.jpeg',
        ),
        type: UniversalFileType.image,
      ),
    ];
  }

  static KeyEventResult handleKeyPress(
    KeyEvent event,
    ComposeState state,
    WidgetRef ref,
    BuildContext context, {
    SnPost? originalPost,
    SnPost? repliedPost,
    SnPost? forwardedPost,
  }) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final isPaste = event.logicalKey == LogicalKeyboardKey.keyV;
    final isSave = event.logicalKey == LogicalKeyboardKey.keyS;
    final isModifierPressed =
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;
    final isSubmit = event.logicalKey == LogicalKeyboardKey.enter;

    if (isPaste && isModifierPressed) {
      handlePaste(state);
      return KeyEventResult.handled;
    } else if (isSave && isModifierPressed) {
      saveDraftManually(ref, state, context);
      return KeyEventResult.handled;
    } else if (isSubmit && isModifierPressed && !state.submitting.value) {
      performAction(
        ref,
        state,
        context,
        originalPost: originalPost,
        repliedPost: repliedPost,
        forwardedPost: forwardedPost,
      );
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
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
    state.tags.dispose();
    state.categories.dispose();
    state.realm.dispose();
    state.embedView.dispose();
    state.embeds.dispose();
    state.thumbnailId.dispose();
    state.collectionIds.dispose();
    state.cloudDraftId.dispose();
  }
}
