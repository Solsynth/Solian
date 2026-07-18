import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/data/database.dart';
import 'package:island/data/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnChatRoom room(String id) {
  final now = DateTime.utc(2026);
  return SnChatRoom(
    id: id,
    name: 'Test room',
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
  );
}

class _StaticChatRoomNotifier extends ChatRoomNotifier {
  @override
  Future<SnChatRoom?> build(String? roomId) async => room(roomId!);
}

class _AnonymousChatRoomIdentityNotifier extends ChatRoomIdentityNotifier {
  @override
  Future<SnChatMember?> build(String? _) async => null;
}

class _EmptyResponseAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions _,
    Stream<Uint8List>? __,
    Future<void>? ___,
  ) async => ResponseBody.fromString(
    '[]',
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MessagesNotifier top-level actions', () {
    late AppDatabase database;
    late ProviderContainer container;
    late ProviderSubscription<AsyncValue<List<LocalChatMessage>>> subscription;

    setUp(() async {
      database = AppDatabase.web();
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          databaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(preferences),
          tokenProvider.overrideWithValue(null),
          apiClientProvider.overrideWithValue(
            Dio()..httpClientAdapter = _EmptyResponseAdapter(),
          ),
          weakInternetModeProvider.overrideWithValue(false),
          chatRoomProvider('room-1').overrideWith(_StaticChatRoomNotifier.new),
          chatRoomIdentityProvider(
            'room-1',
          ).overrideWith(_AnonymousChatRoomIdentityNotifier.new),
        ],
      );
      subscription = container.listen(messagesProvider('room-1'), (_, _) {});
      await container.read(messagesProvider('room-1').future);
    });

    tearDown(() async {
      subscription.close();
      container.dispose();
      await database.close();
    });

    test('empty sends are ignored before any sending work starts', () async {
      final notifier = container.read(messagesProvider('room-1').notifier);

      await notifier.sendMessage('  ', const []);

      expect(container.read(messagesProvider('room-1')).value, isEmpty);
    });

    test('empty search without filters returns immediately', () async {
      final notifier = container.read(messagesProvider('room-1').notifier);

      final results = await notifier.getSearchResults('   ');

      expect(results, isEmpty);
    });

    test('blank shared search clears the visible result set', () async {
      final notifier = container.read(messagesProvider('room-1').notifier);

      await notifier.searchMessages('   ');

      expect(container.read(messagesProvider('room-1')).value, isEmpty);
    });
  });
}
