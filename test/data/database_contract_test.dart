import 'package:flutter_test/flutter_test.dart';
import 'package:island/data/database.web_impl.dart';
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

void main() {
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
  });
}
