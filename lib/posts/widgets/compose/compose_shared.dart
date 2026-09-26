import 'dart:async';
import 'dart:io';

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
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/core/database.dart';
import 'package:island/data/database.dart';
import 'package:island/core/network.dart';
import 'package:island/tasks/app_task.dart';
import 'package:island/tasks/tasks_notifier.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/posts/widgets/compose/quill_markdown.dart';
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
  final ValueNotifier<DateTime?> lastOwnPostPublishedAt;
  final ValueNotifier<bool> chainWithPrevious;
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

  /// WYSIWYG (Quill) editor controller mirroring [contentController]'s
  /// markdown. Changes flow both ways: editor edits are exported back to
  /// [contentController], and external writes to [contentController] (draft
  /// restore, placeholder/attachment insertion) are re-imported into the
  /// document. Owned and disposed with the rest of the state.
  late final QuillController contentQuillController;

  /// True while [contentQuillController] and [contentController] are being
  /// synced, to prevent listener loops.
  bool _syncingContent = false;

  /// Text of [contentController] at the last successful sync. Used to diff
  /// external changes so the editor caret lands after the edit.
  String _lastSyncedText;

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
       lastOwnPostPublishedAt = ValueNotifier<DateTime?>(null),
       chainWithPrevious = ValueNotifier<bool>(true),
       cloudDraftId = ValueNotifier<String?>(cloudDraftId),
       _lastSyncedText = contentController.text {
    contentQuillController = QuillController(
      document: Document.fromJson(
        markdownToQuillDelta(contentController.text).toJson(),
      ),
      selection: const TextSelection.collapsed(offset: 0),
      // ignore: experimental_member_use
      config: QuillControllerConfig(
        // ignore: experimental_member_use
        clipboardConfig: QuillClipboardConfig(
          // ignore: experimental_member_use
          onClipboardPaste: _pasteClipboardMarkdown,
        ),
      ),
    );
    contentController.addListener(_importFromContent);
    contentQuillController.addListener(_exportFromQuill);
  }

  /// Matches line-leading block markers (heading, quote, list, code fence,
  /// table) and inline markers (bold, code, strike, link, image) — enough to
  /// tell pasted markdown apart from prose.
  static final RegExp _markdownPastePattern = RegExp(
    r'^\s{0,3}(#{1,6}\s|>\s?|\s*[-*+]\s|\s*\d+\.\s|```|\|)|'
    r'(\*\*|__|~~|`|!?\[[^\]]*\]\()',
    multiLine: true,
  );

  /// Matches a line that opens a block, which must start a new line.
  static final RegExp _blockMarkerPattern = RegExp(
    r'^\s{0,3}(#{1,6}\s|>\s?|[-*+]\s|\d+\.\s|```|\|| {4})',
  );

  /// Pastes markdown from the system clipboard as rich content.
  ///
  /// flutter_quill's default handler inserts plain text verbatim, so markdown
  /// copied from another editor would land as literal `#`/`-`/`**` characters.
  /// When the clipboard text looks like markdown it is parsed into the same
  /// document structure as typed input; otherwise `false` is returned so the
  /// default handling (rich HTML, links, images, plain text) runs.
  Future<bool> _pasteClipboardMarkdown() async {
    if (!contentQuillController.selection.isValid) return false;
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (text == null || text.trim().isEmpty) return false;
    if (!_markdownPastePattern.hasMatch(text)) return false;

    // A single inline-only line stays in the line it was pasted into instead
    // of pulling the rest of the paragraph down with a paragraph break.
    final inlineOnly =
        !text.contains('\n') && !_blockMarkerPattern.hasMatch(text);
    final delta = inlineOnly
        ? _withoutTrailingNewline(markdownToQuillDelta(text))
        : markdownToQuillDelta(text);
    if (delta.isEmpty) return false;
    final selection = contentQuillController.selection;
    var inserted = 0;
    for (final operation in delta.toList()) {
      final data = operation.data;
      inserted += data is String ? data.length : 1;
    }
    contentQuillController.replaceText(
      selection.start,
      selection.end - selection.start,
      delta,
      TextSelection.collapsed(offset: selection.start + inserted),
    );
    return true;
  }

  /// Drops the paragraph-terminating newline from a delta.
  static Delta _withoutTrailingNewline(Delta delta) {
    final operations = delta.toList();
    final last = operations.last;
    final data = last.data;
    if (data is! String || !data.endsWith('\n')) return delta;
    final trimmed = data.substring(0, data.length - 1);
    final result = Delta();
    for (final operation in operations.take(operations.length - 1)) {
      result.push(operation);
    }
    if (trimmed.isNotEmpty) {
      result.insert(trimmed, last.attributes);
    }
    return result;
  }

  /// Re-imports [contentController]'s markdown into the Quill document when it
  /// changes outside the editor (draft restore, placeholder insertion, reset).
  void _importFromContent() {
    if (_syncingContent) return;
    final newText = contentController.text;
    if (newText == _lastSyncedText) return;
    _syncingContent = true;
    contentQuillController.document = Document.fromJson(
      markdownToQuillDelta(newText).toJson(),
    );
    final caret = _changedCaretOffset(_lastSyncedText, newText);
    if (caret != null && contentQuillController.document.length > 0) {
      contentQuillController.updateSelection(
        TextSelection.collapsed(offset: caret),
        ChangeSource.local,
      );
    }
    _lastSyncedText = newText;
    _syncingContent = false;
  }

  /// Exports the Quill document back to [contentController] as markdown when
  /// the editor changes.
  void _exportFromQuill() {
    if (_syncingContent) return;
    final markdown = quillDeltaToMarkdown(
      contentQuillController.document.toDelta(),
    );
    _syncingContent = true;
    _lastSyncedText = markdown;
    contentController.text = markdown;
    _syncingContent = false;
  }

  /// Inserts [text] into the document at the current editor selection
  /// (replacing any selected range), then syncs the resulting markdown to
  /// [contentController]. Used by toolbar placeholders so the editor caret is
  /// respected exactly.
  void insertContent(String text) {
    final controller = contentQuillController;
    final selection = controller.selection;
    final index = selection.isValid
        ? selection.start
        : controller.document.length;
    controller.replaceText(
      index,
      selection.extentOffset - selection.baseOffset,
      text,
      TextSelection.collapsed(offset: index + text.length),
    );
  }

  /// Wraps the current editor selection with [left] and [right] delimiters for
  /// Solian's inline syntaxes (`=!spoiler!=`, `==highlight==`). A collapsed
  /// caret inserts an empty pair with the caret placed between the delimiters,
  /// and a range keeps the wrapped text selected so it can be replaced.
  void wrapSelection(String left, String right) {
    final controller = contentQuillController;
    final selection = controller.selection;
    final index = selection.isValid
        ? selection.start
        : controller.document.length;
    final end = selection.isValid ? selection.end : index;
    final inner = end > index
        ? controller.document.toPlainText().substring(index, end)
        : '';
    controller.replaceText(
      index,
      end - index,
      '$left$inner$right',
      TextSelection(
        baseOffset: index + left.length,
        extentOffset: index + left.length + inner.length,
      ),
    );
  }

  /// Inserts an image embed for [url] at the current editor selection. Image
  /// attachments are stored as markdown images (`![](solian://files/<id>)`),
  /// so they must become Quill image embeds rather than raw markdown text —
  /// raw text would be re-escaped on export and render literally.
  void insertImage(String url) {
    final controller = contentQuillController;
    final selection = controller.selection;
    final index = selection.isValid
        ? selection.start
        : controller.document.length;
    controller.replaceText(
      index,
      selection.extentOffset - selection.baseOffset,
      BlockEmbed.image(url),
      TextSelection.collapsed(offset: index + 1),
    );
  }

  /// Offset in [newText] just past the region that differs from [oldText], or
  /// null when the texts are identical. Positions the caret after external
  /// edits (insertions/replacements) that share a common prefix/suffix.
  static int? _changedCaretOffset(String oldText, String newText) {
    if (oldText == newText) return null;
    final minLength = oldText.length < newText.length
        ? oldText.length
        : newText.length;
    var prefix = 0;
    while (prefix < minLength && oldText[prefix] == newText[prefix]) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < minLength - prefix &&
        oldText[oldText.length - 1 - suffix] ==
            newText[newText.length - 1 - suffix]) {
      suffix++;
    }
    return prefix + (newText.length - prefix - suffix);
  }

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
  final String? chainedPostId;
  final bool autoChain;

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
    this.chainedPostId,
    this.autoChain = true,
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
    SnPost? chainedPost,
    bool autoChain = true,
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
      chainedPostId: chainedPost?.id,
      autoChain: autoChain,
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
      // Persist the local draft before uploading: the uploads below are
      // network requests and must not be able to lose the draft.
      await _persistLocalDraft(ref, state);

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

  /// Writes the current editor state to the local draft store. Performs no
  /// network request and never uploads attachments, so it is safe to call
  /// before (and again after a failure of) the submission requests: the draft
  /// on disk only ever converges to the content the user sees.
  static Future<void> _persistLocalDraft(
    WidgetRef ref,
    ComposeState state,
  ) async {
    try {
      await _saveLocalDraft(ref.read(databaseProvider), state);
    } catch (e) {
      Logger.root.severe('[ComposeLogic] Failed to persist local draft: $e');
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
      chainedPostId: null,
      chainedPost: null,
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
      chainedPostId: snapshot.chainedPostId,
      chainedPost: null,
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

  /// Converts dropped desktop files into typed [UniversalFile]s and appends them.
  /// Returns the number of files added.
  static int addDroppedFiles(ComposeState state, List<XFile> files) {
    if (files.isEmpty) return 0;

    final newFiles = <UniversalFile>[];
    for (final xfile in files) {
      final provisional = UniversalFile(
        data: xfile,
        type: UniversalFileType.file,
      );
      final mimeType = FileUploader.getMimeType(provisional);
      final fileType = switch (mimeType.split('/').firstOrNull) {
        'image' => UniversalFileType.image,
        'video' => UniversalFileType.video,
        'audio' => UniversalFileType.audio,
        _ => UniversalFileType.file,
      };
      newFiles.add(UniversalFile(data: xfile, type: fileType));
    }

    if (newFiles.isEmpty) return 0;
    state.attachments.value = [...state.attachments.value, ...newFiles];
    return newFiles.length;
  }

  /// Matches inline markdown links and images: `[text](target)` and
  /// `![alt](target)`.
  static final RegExp inlineMarkdownLinkRegex = RegExp(
    r'!?\[[^\]]*\]\(([^)]+)\)',
  );

  /// Matches reference-style link definitions: `[id]: target`.
  static final RegExp markdownReferenceDefinitionRegex = RegExp(
    r'^\s{0,3}\[[^\]]+\]:\s*(.+?)\s*$',
    multiLine: true,
  );

  /// Picks a local markdown file, loads its content into the editor and scans
  /// the markdown for links to local files (inline images/links and reference
  /// definitions). Every referenced file that exists on disk is added to the
  /// attachment list, deduplicated against existing attachments. Returns the
  /// number of attachments added.
  static Future<int> importMarkdownFile(
    WidgetRef ref,
    ComposeState state,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['md', 'markdown'],
    );
    if (result == null || result.files.isEmpty) return 0;
    final filePath = result.files.single.path;
    if (filePath == null) return 0;

    final markdownFile = File(filePath);
    if (!await markdownFile.exists()) return 0;

    state.contentController.text = await markdownFile.readAsString();

    final linkedPaths = resolveLocalFilesFromMarkdown(
      markdownFile.parent.path,
      state.contentController.text,
    );
    if (linkedPaths.isEmpty) return 0;

    final existingPaths = state.attachments.value
        .where((e) => e.data is XFile)
        .map((e) => (e.data as XFile).path)
        .where((p) => p.isNotEmpty)
        .toSet();

    final newFiles = <UniversalFile>[];
    for (final path in linkedPaths) {
      if (!existingPaths.add(path)) continue;
      final file = File(path);
      if (!await file.exists()) continue;
      final name = path.split('/').last;
      final xfile = XFile(
        path,
        name: name.isEmpty ? filePath : name,
        mimeType: lookupMimeType(path) ?? 'application/octet-stream',
      );
      final provisional = UniversalFile(
        data: xfile,
        type: UniversalFileType.file,
      );
      final fileType = switch (FileUploader.getMimeType(provisional)
          .split('/')
          .firstOrNull) {
        'image' => UniversalFileType.image,
        'video' => UniversalFileType.video,
        'audio' => UniversalFileType.audio,
        _ => UniversalFileType.file,
      };
      newFiles.add(UniversalFile(data: xfile, type: fileType));
    }
    if (newFiles.isEmpty) return 0;
    state.attachments.value = [...state.attachments.value, ...newFiles];
    return newFiles.length;
  }

  /// Collects existing local file paths referenced by [content], resolved
  /// against [baseDirectory] (the directory of the imported markdown file).
  /// Remote URLs, anchors and data URIs are ignored.
  static Set<String> resolveLocalFilesFromMarkdown(
    String baseDirectory,
    String content,
  ) {
    final targets = <String>[
      for (final m in inlineMarkdownLinkRegex.allMatches(content))
        m.group(1)!,
      for (final m in markdownReferenceDefinitionRegex.allMatches(content))
        m.group(1)!,
    ];

    final resolved = <String>{};
    for (var target in targets) {
      target = target.trim();
      // `[text](<path>)` — strip wrapping angle brackets.
      if (target.length > 2 &&
          target.startsWith('<') &&
          target.endsWith('>')) {
        target = target.substring(1, target.length - 1).trim();
      }
      // `path "title"` / `path 'title'` — strip the trailing title.
      target = target.replaceFirst(
        RegExp(r'\s+["\x27].*["\x27]$'),
        '',
      );
      if (!_isLocalFileTarget(target)) continue;
      // Normalize Windows separators so absolute/resolution logic is uniform.
      target = target.replaceAll('\\', '/');
      if (target.startsWith('/')) {
        resolved.add(target);
        continue;
      }
      resolved.add('$baseDirectory/$target');
    }
    return resolved;
  }

  /// True when [target] points at a local filesystem path rather than a
  /// remote URL, anchor or data URI.
  static bool _isLocalFileTarget(String target) {
    if (target.isEmpty || target.startsWith('#')) return false;
    if (target.startsWith('data:')) return false;
    final colon = target.indexOf(':');
    if (colon > 0) {
      final scheme = target.substring(0, colon);
      final rest = target.substring(colon + 1);
      // A single-letter scheme followed by a slash is a Windows drive path.
      final isWindowsDrive =
          scheme.length == 1 && (rest.startsWith('/') || rest.startsWith('\\'));
      if (!isWindowsDrive) return false;
    }
    return true;
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
    bool? imageCompressionEnabled,
    int? imageCompressionQuality,
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
            imageCompressionEnabled: imageCompressionEnabled,
            imageCompressionQuality: imageCompressionQuality,
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
    final cloudFile = attachment.data as IDisplayableCloudFile;
    state.insertImage('solian://files/${cloudFile.id}');
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
    SnPost? chainedPost,
    bool autoChain = true,
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

    var published = false;

    try {
      state.submitting.value = true;

      // Persist the draft before the first web request: a failed upload or
      // publish must never cost the user their content.
      await _persistLocalDraft(ref, state);

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
        if (chainedPost != null) 'chained_post_id': chainedPost.id,
        if (!autoChain) 'auto_chain': false,
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

      published = true;

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
      // A failed publish keeps the draft: re-persist the latest state so
      // attachments that did upload and any later edits are on disk. A post
      // that already published stays published — its draft is gone by design.
      if (!published) await _persistLocalDraft(ref, state);

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
    SnPost? chainedPost,
    bool autoChain = true,
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
        chainedPost: chainedPost,
        autoChain: autoChain,
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
        if (snapshot.chainedPostId != null)
          'chained_post_id': snapshot.chainedPostId,
        if (!snapshot.autoChain) 'auto_chain': false,
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
    state.contentQuillController.dispose();
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
