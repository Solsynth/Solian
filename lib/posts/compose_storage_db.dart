import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'compose_storage_db.g.dart';

@riverpod
class ComposeStorageNotifier extends _$ComposeStorageNotifier {
  @override
  Map<String, SnPost> build() {
    _loadDrafts();
    return {};
  }

  Future<void> _loadDrafts() async {
    final drafts = <String, SnPost>{};
    try {
      final database = ref.read(databaseProvider);
      final dbDrafts = await database.getAllPostDrafts();
      if (!ref.mounted) return;
      for (final draft in dbDrafts) {
        drafts[draft.id] = draft;
      }
    } catch (_) {
      // Ignore local load errors and continue with cloud drafts.
    }

    try {
      if (!ref.mounted) return;
      final client = ref.read(apiClientProvider);
      final response = await client.get('/sphere/posts/drafts');
      if (!ref.mounted) return;
      final cloudDrafts = (response.data as List)
          .map((e) => SnPost.fromJson(e as Map<String, dynamic>))
          .toList();
      for (final draft in cloudDrafts) {
        drafts[draft.id] = draft;
      }
    } catch (_) {
      // Keep local drafts if cloud fetch fails.
    }

    // If there's an error loading drafts, start with empty state
    if (!ref.mounted) return;
    state = drafts;
  }

  Future<void> deleteLocalDraft(String id) async {
    final oldDraft = state[id];
    final newState = Map<String, SnPost>.from(state);
    newState.remove(id);
    state = newState;

    try {
      final database = ref.read(databaseProvider);
      await database.deletePostDraft(id);
    } catch (e) {
      if (oldDraft != null && ref.mounted) {
        state = {...state, id: oldDraft};
      }
      rethrow;
    }
  }

  Future<void> saveDraft(SnPost draft) async {
    final updatedDraft = draft.copyWith(updatedAt: DateTime.now());

    try {
      final database = ref.read(databaseProvider);
      await database.addPostDraftFromPost(
        updatedDraft.copyWith(
          updatedAt: updatedDraft.updatedAt ?? DateTime.now(),
        ),
      );
      if (!ref.mounted) return;
      state = {...state, updatedDraft.id: updatedDraft};
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDraft(String id) async {
    final oldDraft = state[id];
    await deleteLocalDraft(id);

    if (oldDraft?.draftedAt != null) {
      try {
        final client = ref.read(apiClientProvider);
        await client.delete('/sphere/posts/$id');
      } catch (_) {
        // Ignore cloud delete errors to avoid blocking local cleanup.
      }
    }
  }

  SnPost? getDraft(String id) {
    return state[id];
  }

  List<SnPost> getAllDrafts() {
    final drafts = state.values.toList();
    drafts.sort(
      (a, b) =>
          (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
    );
    return drafts;
  }

  List<SnPost> getDraftsByType(int type) {
    final drafts = state.values.where((e) => e.type == type).toList();
    drafts.sort(
      (a, b) =>
          (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
    );
    return drafts;
  }

  SnPost? getLatestDraftByType(int type) {
    final drafts = getDraftsByType(type);
    if (drafts.isEmpty) return null;
    return drafts.first;
  }

  Future<SnPost> uploadDraftToCloud(String id) async {
    final draft = state[id];
    if (draft == null) {
      throw Exception('Draft not found');
    }

    final publisherName = draft.publisher?.name;
    if (publisherName == null || publisherName.isEmpty) {
      throw Exception('Cannot upload draft: missing publisher');
    }

    final client = ref.read(apiClientProvider);
    final isCloudDraft = draft.draftedAt != null;
    final endpoint = isCloudDraft ? '/sphere/posts/$id' : '/sphere/posts';
    final payload = {
      'title': draft.title ?? '',
      'description': draft.description ?? '',
      'content': draft.content ?? '',
      if (draft.slug?.isNotEmpty == true) 'slug': draft.slug,
      'visibility': draft.visibility,
      'attachments': draft.attachments.map((e) => e.id).toList(),
      'type': draft.type,
      'tags': draft.tags.map((e) => e.slug).toList(),
      'categories': draft.categories.map((e) => e.slug).toList(),
      if (draft.realm != null) 'realm_id': draft.realm?.id,
      if (draft.meta?['thumbnail'] != null)
        'thumbnail_id': draft.meta?['thumbnail'],
      if (draft.embedView != null) 'embed_view': draft.embedView!.toJson(),
      'drafted_at': DateTime.now().toUtc().toIso8601String(),
      'published_at': null,
    };

    final response = await client.request(
      endpoint,
      queryParameters: {'pub': publisherName},
      data: payload,
      options: Options(method: isCloudDraft ? 'PATCH' : 'POST'),
    );
    final cloudDraft = SnPost.fromJson(response.data);
    await saveDraft(cloudDraft);
    if (!isCloudDraft && id != cloudDraft.id) {
      await deleteLocalDraft(id);
    }
    return cloudDraft;
  }

  Future<void> clearAllDrafts() async {
    state = {};

    try {
      final database = ref.read(databaseProvider);
      await database.clearAllPostDrafts();
    } catch (e) {
      // If clearing fails, we might want to reload from database
      if (ref.mounted) {
        _loadDrafts();
      }
      rethrow;
    }
  }
}
