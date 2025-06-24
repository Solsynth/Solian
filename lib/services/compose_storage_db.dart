import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/database/drift_db.dart';
import 'package:island/pods/database.dart';

part 'compose_storage_db.g.dart';

class ComposeDraftModel {
  final String id;
  final String title;
  final String description;
  final String content;
  final List<String> attachmentIds;
  final String visibility;
  final DateTime lastModified;

  ComposeDraftModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.attachmentIds,
    required this.visibility,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'content': content,
    'attachmentIds': attachmentIds,
    'visibility': visibility,
    'lastModified': lastModified.toIso8601String(),
  };

  factory ComposeDraftModel.fromJson(Map<String, dynamic> json) => ComposeDraftModel(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    content: json['content'] as String? ?? '',
    attachmentIds: List<String>.from(json['attachmentIds'] as List? ?? []),
    visibility: json['visibility'] as String? ?? 'public',
    lastModified: DateTime.parse(json['lastModified'] as String),
  );

  factory ComposeDraftModel.fromDbRow(ComposeDraft row) => ComposeDraftModel(
    id: row.id,
    title: row.title,
    description: row.description,
    content: row.content,
    attachmentIds: List<String>.from(jsonDecode(row.attachmentIds)),
    visibility: row.visibility,
    lastModified: row.lastModified,
  );

  ComposeDraftsCompanion toDbCompanion() => ComposeDraftsCompanion(
    id: Value(id),
    title: Value(title),
    description: Value(description),
    content: Value(content),
    attachmentIds: Value(jsonEncode(attachmentIds)),
    visibility: Value(visibility),
    lastModified: Value(lastModified),
  );

  ComposeDraftModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    List<String>? attachmentIds,
    String? visibility,
    DateTime? lastModified,
  }) {
    return ComposeDraftModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      visibility: visibility ?? this.visibility,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  bool get isEmpty =>
      title.isEmpty &&
      description.isEmpty &&
      content.isEmpty &&
      attachmentIds.isEmpty;
}

class ArticleDraftModel {
  final String id;
  final String title;
  final String description;
  final String content;
  final String visibility;
  final DateTime lastModified;

  ArticleDraftModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.visibility,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'content': content,
    'visibility': visibility,
    'lastModified': lastModified.toIso8601String(),
  };

  factory ArticleDraftModel.fromJson(Map<String, dynamic> json) => ArticleDraftModel(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    content: json['content'] as String? ?? '',
    visibility: json['visibility'] as String? ?? 'public',
    lastModified: DateTime.parse(json['lastModified'] as String),
  );

  factory ArticleDraftModel.fromDbRow(ArticleDraft row) => ArticleDraftModel(
    id: row.id,
    title: row.title,
    description: row.description,
    content: row.content,
    visibility: row.visibility,
    lastModified: row.lastModified,
  );

  ArticleDraftsCompanion toDbCompanion() => ArticleDraftsCompanion(
    id: Value(id),
    title: Value(title),
    description: Value(description),
    content: Value(content),
    visibility: Value(visibility),
    lastModified: Value(lastModified),
  );

  ArticleDraftModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? visibility,
    DateTime? lastModified,
  }) {
    return ArticleDraftModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      visibility: visibility ?? this.visibility,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  bool get isEmpty => title.isEmpty && description.isEmpty && content.isEmpty;
}

@riverpod
class ComposeStorageNotifier extends _$ComposeStorageNotifier {
  @override
  Map<String, ComposeDraftModel> build() {
    _loadDrafts();
    return {};
  }

  void _loadDrafts() async {
    try {
      final database = ref.read(databaseProvider);
      final dbDrafts = await database.getAllComposeDrafts();
      final drafts = <String, ComposeDraftModel>{};
      for (final dbDraft in dbDrafts) {
        final draft = ComposeDraftModel.fromDbRow(dbDraft);
        drafts[draft.id] = draft;
      }
      state = drafts;
    } catch (e) {
      // If there's an error loading drafts, start with empty state
      state = {};
    }
  }

  Future<void> saveDraft(ComposeDraftModel draft) async {
    if (draft.isEmpty) {
      await deleteDraft(draft.id);
      return;
    }

    final updatedDraft = draft.copyWith(lastModified: DateTime.now());
    state = {...state, updatedDraft.id: updatedDraft};
    
    try {
      final database = ref.read(databaseProvider);
      await database.saveComposeDraft(updatedDraft.toDbCompanion());
    } catch (e) {
      // Revert state on error
      final newState = Map<String, ComposeDraftModel>.from(state);
      newState.remove(updatedDraft.id);
      state = newState;
      rethrow;
    }
  }

  Future<void> deleteDraft(String id) async {
    final oldDraft = state[id];
    final newState = Map<String, ComposeDraftModel>.from(state);
    newState.remove(id);
    state = newState;
    
    try {
      final database = ref.read(databaseProvider);
      await database.deleteComposeDraft(id);
    } catch (e) {
      // Revert state on error
      if (oldDraft != null) {
        state = {...state, id: oldDraft};
      }
      rethrow;
    }
  }

  ComposeDraftModel? getDraft(String id) {
    return state[id];
  }

  List<ComposeDraftModel> getAllDrafts() {
    final drafts = state.values.toList();
    drafts.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return drafts;
  }

  Future<void> clearAllDrafts() async {
    state = {};
    
    try {
      final database = ref.read(databaseProvider);
      await database.clearAllComposeDrafts();
    } catch (e) {
      // If clearing fails, we might want to reload from database
      _loadDrafts();
      rethrow;
    }
  }
}

@riverpod
class ArticleStorageNotifier extends _$ArticleStorageNotifier {
  @override
  Map<String, ArticleDraftModel> build() {
    _loadDrafts();
    return {};
  }

  void _loadDrafts() async {
    try {
      final database = ref.read(databaseProvider);
      final dbDrafts = await database.getAllArticleDrafts();
      final drafts = <String, ArticleDraftModel>{};
      for (final dbDraft in dbDrafts) {
        final draft = ArticleDraftModel.fromDbRow(dbDraft);
        drafts[draft.id] = draft;
      }
      state = drafts;
    } catch (e) {
      // If there's an error loading drafts, start with empty state
      state = {};
    }
  }

  Future<void> saveDraft(ArticleDraftModel draft) async {
    if (draft.isEmpty) {
      await deleteDraft(draft.id);
      return;
    }

    final updatedDraft = draft.copyWith(lastModified: DateTime.now());
    state = {...state, updatedDraft.id: updatedDraft};
    
    try {
      final database = ref.read(databaseProvider);
      await database.saveArticleDraft(updatedDraft.toDbCompanion());
    } catch (e) {
      // Revert state on error
      final newState = Map<String, ArticleDraftModel>.from(state);
      newState.remove(updatedDraft.id);
      state = newState;
      rethrow;
    }
  }

  Future<void> deleteDraft(String id) async {
    final oldDraft = state[id];
    final newState = Map<String, ArticleDraftModel>.from(state);
    newState.remove(id);
    state = newState;
    
    try {
      final database = ref.read(databaseProvider);
      await database.deleteArticleDraft(id);
    } catch (e) {
      // Revert state on error
      if (oldDraft != null) {
        state = {...state, id: oldDraft};
      }
      rethrow;
    }
  }

  ArticleDraftModel? getDraft(String id) {
    return state[id];
  }

  List<ArticleDraftModel> getAllDrafts() {
    final drafts = state.values.toList();
    drafts.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return drafts;
  }

  Future<void> clearAllDrafts() async {
    state = {};
    
    try {
      final database = ref.read(databaseProvider);
      await database.clearAllArticleDrafts();
    } catch (e) {
      // If clearing fails, we might want to reload from database
      _loadDrafts();
      rethrow;
    }
  }
}