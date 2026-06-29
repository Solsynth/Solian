import 'package:flutter_test/flutter_test.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  group('ComposeLogic.createState', () {
    test('creates a fresh random draft id for each new state', () {
      final first = ComposeLogic.createState();
      final second = ComposeLogic.createState();

      expect(first.draftId, isNotEmpty);
      expect(second.draftId, isNotEmpty);
      expect(first.draftId, isNot(second.draftId));

      ComposeLogic.dispose(first);
      ComposeLogic.dispose(second);
    });
  });

  group('ComposeLogic.applyDraftToState', () {
    test('rebinds the active draft identity when restoring a local draft', () {
      final state = ComposeLogic.createState();
      final draft = _draft(
        id: 'draft-local',
        title: 'Recovered title',
        content: 'Recovered content',
      );

      ComposeLogic.applyDraftToState(state, draft);

      expect(state.draftId, 'draft-local');
      expect(state.cloudDraftId.value, isNull);
      expect(state.titleController.text, 'Recovered title');
      expect(state.contentController.text, 'Recovered content');

      ComposeLogic.dispose(state);
    });

    test('keeps cloud draft id when restoring a server draft', () {
      final state = ComposeLogic.createState();
      final draft = _draft(
        id: 'draft-cloud',
        title: 'Cloud title',
        draftedAt: DateTime(2026, 6, 29, 12, 0, 0),
      );

      ComposeLogic.applyDraftToState(state, draft);

      expect(state.draftId, 'draft-cloud');
      expect(state.cloudDraftId.value, 'draft-cloud');
      expect(state.titleController.text, 'Cloud title');

      ComposeLogic.dispose(state);
    });
  });
}

SnPost _draft({
  required String id,
  String? title,
  String? content,
  DateTime? draftedAt,
}) {
  final now = DateTime(2026, 6, 29, 12, 0, 0);
  return SnPost(
    id: id,
    title: title,
    description: null,
    language: 'en',
    editedAt: null,
    draftedAt: draftedAt,
    publishedAt: null,
    visibility: 0,
    content: content,
    slug: null,
    type: 0,
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
    realmId: null,
    realm: null,
    attachments: const [],
    publisher: SnPublisher(
      id: 'publisher-1',
      type: 0,
      name: 'publisher',
      nick: 'Publisher',
      createdAt: now,
      updatedAt: now,
    ),
    reactions: const [],
    tags: const [],
    categories: const [],
    collections: const [],
    embedView: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}
