import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:island/data/database.dart' as native;
import 'package:island/data/database_logic.dart';
import 'package:island/data/message.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnChatRoom room(String id, {bool isPinned = false}) {
  final now = DateTime.utc(2026);
  return SnChatRoom(
    id: id,
    name: id,
    description: null,
    type: 0,
    picture: null,
    background: null,
    realmId: null,
    accountId: null,
    realm: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    members: null,
    isPinned: isPinned,
  );
}

SnChatGroup chatGroup(String id, int order, List<String> roomIds) {
  final now = DateTime.utc(2026);
  return SnChatGroup(
    id: id,
    accountId: 'account-1',
    name: id,
    order: order,
    roomIds: roomIds,
    createdAt: now,
    updatedAt: now,
  );
}

LocalChatMessage message(String id, {String? threadId}) => LocalChatMessage(
  id: id,
  roomId: 'room-1',
  senderId: 'account-1',
  sender: null,
  data: const {},
  createdAt: DateTime.utc(2026),
  clientMessageId: null,
  status: MessageStatus.sent,
  type: 'text',
  meta: const {},
  membersMentioned: const [],
  attachments: const [],
  reactions: const [],
  threadId: threadId,
);
SnAccount account(String id) {
  final now = DateTime.utc(2026);
  return SnAccount(
    id: id,
    name: id,
    nick: id,
    language: '',
    isSuperuser: false,
    automatedId: null,
    profile: SnAccountProfile(
      id: id,
      experience: 0,
      level: 1,
      levelingProgress: 0,
      picture: null,
      background: null,
      verification: null,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    ),
    perkSubscription: null,
    activatedAt: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}

SnChatMember member(String roomId) {
  final now = DateTime.utc(2026);
  return SnChatMember(
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    id: 'member-$roomId',
    chatRoomId: roomId,
    chatRoom: null,
    accountId: 'account-1',
    account: account('account-1'),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDatabase contract', () {
    test(
      'room refresh preserves local pinning and override removes stale rooms',
      () async {
        final database = AppDatabase.web();
        await database.saveChatRooms([
          room('keep', isPinned: true),
          room('old'),
        ]);

        await database.saveChatRooms([room('keep')], override: true);

        expect((await database.getChatRoomById('keep'))?.isPinned, isTrue);
        expect(await database.getChatRoomById('old'), isNull);
        expect((await database.getDatabaseStats())['chatRooms'], 1);
      },
    );

    test(
      'room refresh removes stale group references and room secrets',
      () async {
        final database = AppDatabase.web();
        await database.saveChatRooms([room('keep'), room('old')]);
        await database.saveChatGroups('account-1', [
          chatGroup('group-1', 1, ['keep', 'old']),
        ]);
        await database.setSecret('chat_room_encryption_mode_old', '1');

        await database.saveChatRooms([room('keep')], override: true);

        expect((await database.getChatGroups('account-1')).single.roomIds, [
          'keep',
        ]);
        expect(
          await database.getSecret('chat_room_encryption_mode_old'),
          isNull,
        );
      },
    );

    test(
      'group assignment moves a room to one group and keeps groups ordered',
      () async {
        final database = AppDatabase.web();
        await database.saveChatGroups('account-1', [
          chatGroup('later', 2, ['room-1']),
          chatGroup('first', 1, ['room-2']),
        ]);

        await database.assignChatRoomToGroup(
          'account-1',
          'room-1',
          groupId: 'first',
        );

        final groups = await database.getChatGroups('account-1');
        expect(groups.map((item) => item.id), ['first', 'later']);
        expect(groups.first.roomIds, containsAll(['room-1', 'room-2']));
        expect(groups.last.roomIds, isNot(contains('room-1')));
      },
    );
    test(
      'deleting local room data removes the room, messages, senders, groups, and secret',
      () async {
        final database = AppDatabase.web();
        await database.saveChatRooms([room('room-1')]);
        await database.saveMessage(message('message-1'));
        await database.saveMember(member('room-1'));
        await database.saveChatGroups('account-1', [
          chatGroup('group-1', 1, ['room-1', 'other-room']),
        ]);
        await database.setSecret('chat_room_encryption_mode_room-1', '3');

        await database.deleteChatRoomLocalData('room-1');

        expect(await database.getChatRoomById('room-1'), isNull);
        expect(await database.getMembersByRoomId('room-1'), isEmpty);
        expect(await database.getMessagesForRoom('room-1'), isEmpty);
        expect((await database.getChatGroups('account-1')).single.roomIds, [
          'other-room',
        ]);
        expect(
          await database.getSecret('chat_room_encryption_mode_room-1'),
          isNull,
        );
      },
    );

    test('reset clears every application-level store', () async {
      final database = AppDatabase.web();
      await database.saveChatRooms([room('room-1')]);
      await database.saveChatGroups('account-1', [chatGroup('group-1', 1, [])]);
      await database.setSecret('cursor', '123');

      await database.reset();

      expect(await database.getAllChatRooms(), isEmpty);
      expect(await database.getChatGroups('account-1'), isEmpty);
      expect(await database.getAllSecrets(), isEmpty);
      expect(await database.getDatabaseStats(), containsPair('chatRooms', 0));
    });

    test('transaction returns its action result', () async {
      final database = AppDatabase.web();

      final result = await database.transaction(() async => 'complete');

      expect(result, 'complete');
    });

    test(
      'thread replies persist their thread_id across a save/restore roundtrip',
      () async {
        final database = AppDatabase.web();
        await database.saveMessage(message('top-level'));
        await database.saveMessage(message('thread-reply', threadId: 'root-1'));

        // Simulate app restart: rebuild from the persisted payloads.
        final restored = AppDatabase.web();
        restored.restoreMessagePayloads(database.exportMessagePayloads());

        final restoredReply = await restored.getMessageById('thread-reply');
        expect(restoredReply?.threadId, 'root-1');
        final restoredTop = await restored.getMessageById('top-level');
        expect(restoredTop?.threadId, isNull);

        // The persisted payload keeps the structural message fields intact
        // alongside the thread id.
        final payload =
            (database.exportMessagePayloads()['thread-reply'] as Map);
        expect(payload, contains('attachments'));
        expect(payload, contains('reactions'));
        expect(payload, contains('repliedMessageId'));
        expect(payload['threadId'], 'root-1');
      },
    );

    test('main message list skips in-thread replies', () async {
      final database = AppDatabase.web();
      await database.saveMessage(message('top-level'));
      await database.saveMessage(message('thread-reply', threadId: 'root-1'));

      final list = await database.getMessagesForRoom('room-1');
      expect(list.map((m) => m.id), ['top-level']);
      expect(await database.getTotalMessagesForRoom('room-1'), 1);
    });
  });

  test('native adapter persists rooms through Drift', () async {
    final directory = await Directory.systemTemp.createTemp('island-drift-');
    addTearDown(() => directory.delete(recursive: true));

    final first = native.AppDatabase.native(Future.value(directory.path));
    await first.saveChatRooms([room('persisted')]);
    await first.close();

    final reopened = native.AppDatabase.native(Future.value(directory.path));
    expect((await reopened.getChatRoomById('persisted'))?.id, 'persisted');
    await reopened.close();
  });

  test('native adapter persists thread_id across a Drift reopen', () async {
    final directory = await Directory.systemTemp.createTemp('island-drift-');
    addTearDown(() => directory.delete(recursive: true));

    final first = native.AppDatabase.native(Future.value(directory.path));
    await first.saveMessage(message('thread-reply', threadId: 'root-1'));
    await first.close();

    final reopened = native.AppDatabase.native(Future.value(directory.path));
    expect((await reopened.getMessageById('thread-reply'))?.threadId, 'root-1');
    await reopened.close();
  });

  test('message thread fields survive the remote-to-local roundtrip', () {
    final remote = SnChatMessage(
      id: 'm1',
      chatRoomId: 'room-1',
      senderId: 'account-1',
      sender: SnChatMember(
        id: 'account-1',
        chatRoomId: 'room-1',
        chatRoom: null,
        accountId: 'account-1',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        deletedAt: null,
        account: account('account-1'),
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
      ),
      type: 'text',
      content: 'root',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      isThreadRoot: true,
      threadRepliesCount: 3,
      threadReplies: const [],
    );

    final local = LocalChatMessage.fromRemoteMessage(
      remote,
      MessageStatus.sent,
    );
    expect(local.data['is_thread_root'], isTrue);
    expect(local.data['thread_replies_count'], 3);

    // Thread counters are carried in the persisted `data` payload (same as
    // reactions), so they survive an encode/decode roundtrip.
    final dataJson = jsonDecode(local.toDataJson());
    expect(dataJson['is_thread_root'], isTrue);
    expect(dataJson['thread_replies_count'], 3);

    // Reconstructing from the persisted data yields the same thread fields.
    final restored = local.toRemoteMessage();
    expect(restored.isThreadRoot, isTrue);
    expect(restored.threadRepliesCount, 3);
  });

  test('native adapter deletes all local room data from Drift', () async {
    final directory = await Directory.systemTemp.createTemp('island-drift-');
    addTearDown(() => directory.delete(recursive: true));

    final first = native.AppDatabase.native(Future.value(directory.path));
    await first.saveChatRooms([room('room-1')]);
    await first.saveMessage(message('persisted-message'));
    await first.saveMember(member('room-1'));
    await first.saveChatGroups('account-1', [
      chatGroup('group-1', 1, ['room-1']),
    ]);
    await first.setSecret('chat_room_encryption_mode_room-1', '3');
    await first.deleteChatRoomLocalData('room-1');
    await first.close();

    final reopened = native.AppDatabase.native(Future.value(directory.path));
    expect(await reopened.getChatRoomById('room-1'), isNull);
    expect(await reopened.getMembersByRoomId('room-1'), isEmpty);
    expect(await reopened.getMessageById('persisted-message'), isNull);
    expect((await reopened.getChatGroups('account-1')).single.roomIds, isEmpty);
    expect(
      await reopened.getSecret('chat_room_encryption_mode_room-1'),
      isNull,
    );
    await reopened.close();
  });

  test(
    'native transaction restores its prior snapshot after failure',
    () async {
      final directory = await Directory.systemTemp.createTemp('island-drift-');
      addTearDown(() => directory.delete(recursive: true));

      final database = native.AppDatabase.native(Future.value(directory.path));
      await database.setSecret('stable', 'value');

      await expectLater(
        database.transaction(() async {
          await database.setSecret('temporary', 'value');
          throw StateError('abort');
        }),
        throwsStateError,
      );
      await database.close();

      final reopened = native.AppDatabase.native(Future.value(directory.path));
      expect(await reopened.getSecret('stable'), 'value');
      expect(await reopened.getSecret('temporary'), isNull);
      await reopened.close();
    },
  );
}
