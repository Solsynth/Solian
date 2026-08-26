import 'dart:async';
import 'dart:convert';
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

SnChatMember member(String roomId) {
  final now = DateTime.utc(2026);
  final profile = SnAccountProfile(
    id: 'profile-1',
    experience: 0,
    level: 1,
    levelingProgress: 0,
    picture: null,
    background: null,
    verification: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
  final account = SnAccount(
    id: 'account-1',
    name: 'test-user',
    nick: 'Test User',
    language: 'en',
    isSuperuser: false,
    automatedId: null,
    profile: profile,
    perkSubscription: null,
    activatedAt: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
  return SnChatMember(
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    id: 'member-$roomId',
    chatRoomId: roomId,
    chatRoom: null,
    accountId: account.id,
    account: account,
    nick: null,
    notify: 0,
    joinedAt: now,
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

SnChatMessage message(String roomId) {
  final now = DateTime.utc(2026);
  final sender = member(roomId);
  return SnChatMessage(
    createdAt: now,
    updatedAt: now,
    id: 'message-1',
    content: 'hello',
    senderId: sender.id,
    sender: sender,
    chatRoomId: roomId,
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
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async => ResponseBody.fromString(
    '[]',
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

/// Adapter that holds the request in flight until the test completes it,
/// simulating a slow/weak network.
class _BlockingResponseAdapter implements HttpClientAdapter {
  final Completer<ResponseBody> completer = Completer<ResponseBody>();

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions _,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) {
    return completer.future;
  }
}

class _BatchedMessagesResponseAdapter implements HttpClientAdapter {
  final List<Map<String, dynamic>> newestMessages;
  final List<Map<String, dynamic>> olderMessages;
  final Completer<void> olderRequestStarted = Completer<void>();
  final Completer<ResponseBody> olderResponse = Completer<ResponseBody>();

  _BatchedMessagesResponseAdapter({
    required this.newestMessages,
    required this.olderMessages,
  });

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) {
    final offset = int.tryParse(options.queryParameters['offset'].toString());
    final messages = offset == 0 ? newestMessages : olderMessages;
    if (offset != 0 && !olderRequestStarted.isCompleted) {
      olderRequestStarted.complete();
      return olderResponse.future;
    }

    return Future.value(
      ResponseBody.fromString(
        jsonEncode(messages),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
          'x-total': ['60'],
        },
      ),
    );
  }
}

Map<String, dynamic> messageJson(String id, DateTime createdAt) {
  final json = message('room-1').toJson();
  json['id'] = id;
  json['created_at'] = createdAt.toIso8601String();
  json['updated_at'] = createdAt.toIso8601String();
  return json;
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
    test(
      'emits a stored realtime message when global sync won the race',
      () async {
        final remote = message('room-1');
        final stored = LocalChatMessage.fromRemoteMessage(
          remote,
          MessageStatus.sent,
        );
        await database.saveMessageWithSender(stored);

        final notifier = container.read(messagesProvider('room-1').notifier);
        await notifier.receiveMessage(remote);

        expect(
          container
              .read(messagesProvider('room-1'))
              .value!
              .map((item) => item.id),
          contains(remote.id),
        );
      },
    );
    test(
      'renders newest messages before background older-history prefetch completes',
      () async {
        final now = DateTime.utc(2026, 1, 1, 12);
        final newest = List.generate(
          20,
          (index) =>
              messageJson('new-$index', now.subtract(Duration(minutes: index))),
        );
        final older = List.generate(
          40,
          (index) => messageJson(
            'old-$index',
            now.subtract(Duration(minutes: 20 + index)),
          ),
        );
        final adapter = _BatchedMessagesResponseAdapter(
          newestMessages: newest,
          olderMessages: older,
        );
        container.read(apiClientProvider).httpClientAdapter = adapter;

        final notifier = container.read(messagesProvider('room-1').notifier);
        final load = notifier.loadInitial(forceRemoteRefresh: true);

        await adapter.olderRequestStarted.future;
        await load;
        expect(
          container
              .read(messagesProvider('room-1'))
              .value!
              .map((item) => item.id),
          orderedEquals(List.generate(20, (index) => 'new-$index')),
        );

        adapter.olderResponse.complete(
          ResponseBody.fromString(
            jsonEncode(older),
            200,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
              'x-total': ['60'],
            },
          ),
        );
        for (var i = 0; i < 5; i++) {
          await pumpEventQueue();
        }

        expect(container.read(messagesProvider('room-1')).value, hasLength(60));
      },
    );

    test('global syncing flag clears when the room notifier is disposed '
        'mid-load (slow network, user leaves the room)', () async {
      // Hold the room's message fetch in flight so the load outlives the
      // room-scoped notifier.
      final blocking = _BlockingResponseAdapter();
      container.read(apiClientProvider).httpClientAdapter = blocking;

      final notifier = container.read(messagesProvider('room-1').notifier);
      final load = notifier.loadInitial(forceRemoteRefresh: true);

      await pumpEventQueue();
      expect(container.read(chatSyncingProvider), isTrue);

      // Drop the last listener while the request is still pending, which
      // disposes the room-scoped notifier.
      subscription.close();
      await pumpEventQueue();

      // The slow request eventually resolves, but the notifier is already
      // disposed: the global syncing flag must still be cleared.
      blocking.completer.complete(
        ResponseBody.fromString(
          '[]',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        ),
      );
      await load;
      await pumpEventQueue();

      expect(container.read(chatSyncingProvider), isFalse);
    });

    test(
      'upload progress mutates an unmodifiable-meta placeholder without '
      'throwing',
      () async {
        final notifier = container.read(messagesProvider('room-1').notifier);

        // The SDK freezed getter exposes `meta` through an
        // EqualUnmodifiableMapView, so a placeholder parsed from the server
        // (as in MessageSender._sendWithAttachmentPlaceholder) carries an
        // unmodifiable meta map. In-place progress writes used to throw
        // "Unsupported operation: Cannot modify unmodifiable map".
        final placeholderJson = {
          'id': 'placeholder-1',
          'type': 'placeholder',
          'content': null,
          'meta': {'placeholder_kind': 'uploading'},
          'created_at': DateTime.utc(2026).toIso8601String(),
          'updated_at': DateTime.utc(2026).toIso8601String(),
          'sender_id': 'member-room-1',
          'sender': member('room-1').toJson(),
          'chat_room_id': 'room-1',
        };
        final placeholderMessage = SnChatMessage.fromJson(placeholderJson);
        expect(
          () => placeholderMessage.meta['placeholder_kind'] = 'boom',
          throwsUnsupportedError,
        );

        // Same path MessageSender takes: parse into a pending LocalChatMessage.
        final placeholder = LocalChatMessage.fromRemoteMessage(
          placeholderMessage,
          MessageStatus.pending,
        );
        await notifier.receiveMessage(
          placeholderMessage,
          applySideEffects: false,
        );
        expect(
          container
              .read(messagesProvider('room-1'))
              .value!
              .map((item) => item.id),
          contains('placeholder-1'),
        );

        // Own upload progress (sender path)
        notifier.updatePendingMessageProgress('placeholder-1', 0.42);
        // Remote upload progress via typing events (receiver path)
        notifier.updatePlaceholderProgressBySender('member-room-1', 0.66);

        final visible = container
            .read(messagesProvider('room-1'))
            .value!
            .firstWhere((item) => item.id == 'placeholder-1');
        expect(visible.meta['placeholder_progress'], 0.66);
        expect(
          () => placeholder.meta['placeholder_kind'] = 'boom',
          throwsUnsupportedError,
        );
      },
    );
  });
}
