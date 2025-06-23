import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/pods/config.dart';

part 'compose_storage.g.dart';

const kComposeDraftStoreKey = 'compose_drafts';
const kArticleDraftStoreKey = 'article_drafts';

class ComposeDraft {
  final String id;
  final String title;
  final String description;
  final String content;
  final List<String> attachmentIds;
  final String visibility;
  final DateTime lastModified;

  ComposeDraft({
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

  factory ComposeDraft.fromJson(Map<String, dynamic> json) => ComposeDraft(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    content: json['content'] as String? ?? '',
    attachmentIds: List<String>.from(json['attachmentIds'] as List? ?? []),
    visibility: json['visibility'] as String? ?? 'public',
    lastModified: DateTime.parse(json['lastModified'] as String),
  );

  ComposeDraft copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    List<String>? attachmentIds,
    String? visibility,
    DateTime? lastModified,
  }) {
    return ComposeDraft(
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

class ArticleDraft {
  final String id;
  final String title;
  final String description;
  final String content;
  final String visibility;
  final DateTime lastModified;

  ArticleDraft({
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

  factory ArticleDraft.fromJson(Map<String, dynamic> json) => ArticleDraft(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    content: json['content'] as String? ?? '',
    visibility: json['visibility'] as String? ?? 'public',
    lastModified: DateTime.parse(json['lastModified'] as String),
  );

  ArticleDraft copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? visibility,
    DateTime? lastModified,
  }) {
    return ArticleDraft(
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
  Map<String, ComposeDraft> build() {
    _loadDrafts();
    return {};
  }

  void _loadDrafts() {
    final prefs = ref.read(sharedPreferencesProvider);
    final draftsJson = prefs.getString(kComposeDraftStoreKey);
    if (draftsJson != null) {
      try {
        final Map<String, dynamic> draftsMap = jsonDecode(draftsJson);
        final drafts = <String, ComposeDraft>{};
        for (final entry in draftsMap.entries) {
          drafts[entry.key] = ComposeDraft.fromJson(entry.value);
        }
        state = drafts;
      } catch (e) {
        // If there's an error loading drafts, start with empty state
        state = {};
      }
    }
  }

  Future<void> _saveDrafts() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final draftsMap = <String, dynamic>{};
    for (final entry in state.entries) {
      draftsMap[entry.key] = entry.value.toJson();
    }
    await prefs.setString(kComposeDraftStoreKey, jsonEncode(draftsMap));
  }

  Future<void> saveDraft(ComposeDraft draft) async {
    if (draft.isEmpty) {
      await deleteDraft(draft.id);
      return;
    }

    final updatedDraft = draft.copyWith(lastModified: DateTime.now());
    state = {...state, updatedDraft.id: updatedDraft};
    await _saveDrafts();
  }

  Future<void> deleteDraft(String id) async {
    final newState = Map<String, ComposeDraft>.from(state);
    newState.remove(id);
    state = newState;
    await _saveDrafts();
  }

  ComposeDraft? getDraft(String id) {
    return state[id];
  }

  List<ComposeDraft> getAllDrafts() {
    final drafts = state.values.toList();
    drafts.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return drafts;
  }

  Future<void> clearAllDrafts() async {
    state = {};
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(kComposeDraftStoreKey);
  }
}

@riverpod
class ArticleStorageNotifier extends _$ArticleStorageNotifier {
  @override
  Map<String, ArticleDraft> build() {
    _loadDrafts();
    return {};
  }

  void _loadDrafts() {
    final prefs = ref.read(sharedPreferencesProvider);
    final draftsJson = prefs.getString(kArticleDraftStoreKey);
    if (draftsJson != null) {
      try {
        final Map<String, dynamic> draftsMap = jsonDecode(draftsJson);
        final drafts = <String, ArticleDraft>{};
        for (final entry in draftsMap.entries) {
          drafts[entry.key] = ArticleDraft.fromJson(entry.value);
        }
        state = drafts;
      } catch (e) {
        // If there's an error loading drafts, start with empty state
        state = {};
      }
    }
  }

  Future<void> _saveDrafts() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final draftsMap = <String, dynamic>{};
    for (final entry in state.entries) {
      draftsMap[entry.key] = entry.value.toJson();
    }
    await prefs.setString(kArticleDraftStoreKey, jsonEncode(draftsMap));
  }

  Future<void> saveDraft(ArticleDraft draft) async {
    if (draft.isEmpty) {
      await deleteDraft(draft.id);
      return;
    }

    final updatedDraft = draft.copyWith(lastModified: DateTime.now());
    state = {...state, updatedDraft.id: updatedDraft};
    await _saveDrafts();
  }

  Future<void> deleteDraft(String id) async {
    final newState = Map<String, ArticleDraft>.from(state);
    newState.remove(id);
    state = newState;
    await _saveDrafts();
  }

  ArticleDraft? getDraft(String id) {
    return state[id];
  }

  List<ArticleDraft> getAllDrafts() {
    final drafts = state.values.toList();
    drafts.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return drafts;
  }

  Future<void> clearAllDrafts() async {
    state = {};
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(kArticleDraftStoreKey);
  }
}
