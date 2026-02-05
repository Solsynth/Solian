import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:island/data/drift_db.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/core/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'compose_storage_db.g.dart';

@riverpod
class ComposeStorageNotifier extends _$ComposeStorageNotifier {
  @override
  Map<String, SnPost> build() {
    _loadDrafts();
    return {};
  }

  void _loadDrafts() async {
    try {
      final database = ref.read(databaseProvider);
      final dbDrafts = await database.getAllPostDrafts();
      final drafts = <String, SnPost>{};
      for (final draft in dbDrafts) {
        drafts[draft.id] = draft;
      }
      state = drafts;
    } catch (e) {
      // If there's an error loading drafts, start with empty state
      state = {};
    }
  }

  Future<void> saveDraft(SnPost draft) async {
    final updatedDraft = draft.copyWith(updatedAt: DateTime.now());

    try {
      final database = ref.read(databaseProvider);
      await database.addPostDraft(
        PostDraftsCompanion(
          id: Value(updatedDraft.id),
          title: Value(updatedDraft.title),
          description: Value(updatedDraft.description),
          content: Value(updatedDraft.content),
          visibility: Value(updatedDraft.visibility),
          type: Value(updatedDraft.type),
          lastModified: Value(updatedDraft.updatedAt ?? DateTime.now()),
          postData: Value(jsonEncode(updatedDraft.toJson())),
        ),
      );
      // Update state after successful database operation, delayed to avoid widget building issues
      Future(() {
        state = {...state, updatedDraft.id: updatedDraft};
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDraft(String id) async {
    final oldDraft = state[id];
    final newState = Map<String, SnPost>.from(state);
    newState.remove(id);
    state = newState;

    try {
      final database = ref.read(databaseProvider);
      await database.deletePostDraft(id);
    } catch (e) {
      // Revert state on error
      if (oldDraft != null) {
        state = {...state, id: oldDraft};
      }
      rethrow;
    }
  }

  SnPost? getDraft(String id) {
    return state[id];
  }

  List<SnPost> getAllDrafts() {
    final drafts = state.values.toList();
    drafts.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
    return drafts;
  }

  Future<void> clearAllDrafts() async {
    state = {};

    try {
      final database = ref.read(databaseProvider);
      await database.clearAllPostDrafts();
    } catch (e) {
      // If clearing fails, we might want to reload from database
      _loadDrafts();
      rethrow;
    }
  }
}
