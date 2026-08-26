import 'package:flutter_test/flutter_test.dart';
import 'package:island/chat/widgets/chat_thread_panel.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnChatMember _member() {
  return SnChatMember(
    id: 'account-1',
    chatRoomId: 'room-1',
    chatRoom: null,
    accountId: 'account-1',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    deletedAt: null,
    account: SnAccount(
      id: 'account-1',
      name: 'a',
      nick: 'alice',
      language: '',
      isSuperuser: false,
      automatedId: null,
      profile: SnAccountProfile(
        id: 'account-1',
        experience: 0,
        level: 1,
        levelingProgress: 0,
        picture: null,
        background: null,
        verification: null,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        deletedAt: null,
      ),
      perkSubscription: null,
      activatedAt: null,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    ),
    nick: null,
    notify: 0,
    joinedAt: null,
    breakUntil: null,
    timeoutUntil: null,
    chatGroupId: null,
    chatGroup: null,
    lastReadAt: null,
    status: null,
    realmNick: null,
    realmBio: null,
    realmExperience: null,
    realmLevel: null,
    realmLevelingProgress: null,
    realmLabel: null,
  );
}

SnChatMessage _msg(
  String id,
  String content,
  DateTime createdAt, {
  String? repliedMessageId,
  int threadRepliesCount = 0,
}) {
  return SnChatMessage(
    id: id,
    chatRoomId: 'room-1',
    senderId: 'account-1',
    sender: _member(),
    type: 'text',
    content: content,
    createdAt: createdAt,
    updatedAt: createdAt,
    repliedMessageId: repliedMessageId,
    threadRepliesCount: threadRepliesCount,
  );
}

void main() {
  group('buildThreadDisplayMessages', () {
    test('orders replies oldest-first and keeps the root first', () {
      final root = _msg('root', '123', DateTime.utc(2026, 8, 7, 17, 21));
      final replies = [
        ThreadReplyNode(
          message: _msg('r1', 'sure', DateTime.utc(2026, 8, 7, 22, 52)),
          depth: 1,
        ),
        ThreadReplyNode(
          message: _msg('r2', 'wdyt', DateTime.utc(2026, 8, 7, 22, 13)),
          depth: 1,
        ),
        ThreadReplyNode(
          message: _msg('r3', '确实好', DateTime.utc(2026, 8, 7, 20, 17)),
          depth: 1,
        ),
      ];

      final messages = buildThreadDisplayMessages(root: root, replies: replies);

      expect(messages.map((m) => m.id).toList(), ['root', 'r3', 'r2', 'r1']);
    });

    test('strips reply references from thread replies', () {
      final root = _msg('root', '123', DateTime.utc(2026, 8, 7, 17, 21));
      final replies = [
        ThreadReplyNode(
          message: _msg(
            'r1',
            'hi',
            DateTime.utc(2026, 8, 7, 20),
            repliedMessageId: 'root',
          ),
          depth: 1,
        ),
      ];

      final messages = buildThreadDisplayMessages(root: root, replies: replies);

      // In-thread replies are flat, so no quoted "reply to" preview is shown.
      expect(messages[1].id, 'r1');
      expect(messages[1].repliedMessageId, isNull);
    });

    test('suppresses the thread-hint chip on the root', () {
      final root = _msg(
        'root',
        '123',
        DateTime.utc(2026, 8, 7, 17, 21),
        threadRepliesCount: 3,
      );
      final replies = [
        ThreadReplyNode(
          message: _msg('r1', 'hi', DateTime.utc(2026, 8, 7, 20)),
          depth: 1,
        ),
      ];

      final messages = buildThreadDisplayMessages(root: root, replies: replies);

      // The user is already inside the thread, so the root's reply-count chip
      // is stripped from the display copy.
      expect(messages[0].id, 'root');
      expect(messages[0].threadRepliesCount, 0);
    });
  });
}
