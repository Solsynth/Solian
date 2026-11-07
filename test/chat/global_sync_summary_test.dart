import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/data/database.dart';
import 'package:island/core/websocket.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A websocket service the test pushes frames into directly.
class _FakeWebSocketService extends SolarWebSocketService {
  _FakeWebSocketService() : super(uri: () => Uri(), token: () async => null);

  final _controller = StreamController<WebSocketPacket>.broadcast();

  void push(SnChatMessage message) => _controller.add(
    WebSocketPacket.fromJson({
      'type': 'messages.new',
      'data': message.toJson(),
      '_ack_id': 'ack-${message.id}',
    }),
  );

  @override
  Stream<WebSocketPacket> get dataStream => _controller.stream;
}

class _SignedOutUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

/// Signed in as the room member, so the summary consults the member row's
/// notify setting and read marker.
class _SignedInUserInfo extends UserInfoNotifier {
  _SignedInUserInfo(this._account);

  final SnAccount _account;

  @override
  Future<SnAccount?> build() async => _account;
}

SnChatMember _member(DateTime now) => SnChatMember(
  createdAt: now,
  updatedAt: now,
  deletedAt: null,
  id: 'member-1',
  chatRoomId: 'room-1',
  chatRoom: null,
  accountId: 'account-1',
  account: SnAccount(
    id: 'account-1',
    name: 'other',
    nick: 'Other',
    language: 'en',
    isSuperuser: false,
    automatedId: null,
    profile: SnAccountProfile(
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
    ),
    perkSubscription: null,
    activatedAt: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  ),
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

/// Serves one room whose summary starts empty, then the queued sync pages.
class _SyncAdapter implements HttpClientAdapter {
  _SyncAdapter(this.pages);

  /// Pages returned to successive `POST /messager/chat/sync` calls.
  final List<List<SnChatMessage>> pages;
  int _syncCall = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async {
    if (options.path.endsWith('/messager/chat/summary')) {
      return ResponseBody.fromString(
        jsonEncode({
          'room-1': {
            'unread_count': 0,
            'has_unread': false,
            'last_message': null,
          },
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    if (options.path.endsWith('/messager/chat/sync')) {
      final page = pages[_syncCall.clamp(0, pages.length - 1)];
      _syncCall += 1;
      final newest = page.isEmpty
          ? DateTime.utc(2026)
          : page.last.createdAt;
      return ResponseBody.fromString(
        jsonEncode({
          'messages': page.map((message) => message.toJson()).toList(),
          'current_timestamp': newest.toIso8601String(),
          'current_message_id': page.isEmpty ? null : page.last.id,
          'total_count': page.length,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    return ResponseBody.fromString(
      '[]',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'x-total': ['0'],
      },
    );
  }
}

/// A message from another member of the room. The signed-in member is
/// `member-1`, and the server excludes a member's own rows from unread, so the
/// sender must be a peer for the unread assertions to mean anything.
SnChatMessage _message(String id, DateTime at) => SnChatMessage(
  createdAt: at,
  updatedAt: at,
  id: id,
  content: 'hello from $id',
  senderId: 'member-2',
  sender: _member(at).copyWith(id: 'member-2'),
  chatRoomId: 'room-1',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatGlobalSyncNotifier room-list summary', () {
    late ProviderContainer container;
    late _FakeWebSocketService ws;
    late AppDatabase database;

    /// Builds a container whose message sync serves [pages], with the sync
    /// cursor already saved so the sync runs instead of skipping. Passing
    /// [member] signs the app in as that member and stores its room row.
    Future<void> pump(
      List<List<SnChatMessage>> pages, {
      SnChatMember? member,
    }) async {
      SharedPreferences.setMockInitialValues({
        'chat_messages_sync_cursor_ms': DateTime.utc(
          2026,
        ).millisecondsSinceEpoch,
      });
      final prefs = await SharedPreferences.getInstance();
      database = AppDatabase.web();
      ws = _FakeWebSocketService();
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          databaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenProvider.overrideWithValue(null),
          websocketProvider.overrideWithValue(ws),
          userInfoProvider.overrideWith(
            member == null
                ? _SignedOutUserInfo.new
                : () => _SignedInUserInfo(member.account),
          ),
          apiClientProvider.overrideWithValue(
            Dio()..httpClientAdapter = _SyncAdapter(pages),
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
      });
      if (member != null) await database.saveMember(member);
      // The summary must be loaded before the sync, as it is on the list.
      await container.read(chatSummaryProvider.future);
      await container.read(chatGlobalSyncProvider.future);
    }

    SnChatSummary? summary() =>
        container.read(chatSummaryProvider).value?['room-1'];

    test('synced messages become the room preview and count as unread', () async {
      final at = DateTime.utc(2026, 1, 2);
      await pump([
        [_message('m1', at)],
        [],
      ]);

      await container.read(chatGlobalSyncProvider.notifier).syncAllMessages();

      expect(summary()?.lastMessage?.id, 'm1');
      expect(summary()?.unreadCount, 1);
      expect(summary()?.hasUnread, isTrue);
    });

    test('a re-synced copy of a stored message does not count twice', () async {
      final at = DateTime.utc(2026, 1, 2);
      // The same row delivered again: a resumed cursor replays what the store
      // already holds.
      await pump([
        [_message('m1', at)],
        [_message('m1', at)],
      ]);

      final notifier = container.read(chatGlobalSyncProvider.notifier);
      await notifier.syncAllMessages();
      final firstUnread = summary()?.unreadCount;
      await notifier.syncAllMessages(force: true);

      expect(firstUnread, 1);
      expect(summary()?.unreadCount, 1);
      expect(summary()?.lastMessage?.id, 'm1');
    });

    test('a message repeated within one page counts once', () async {
      final at = DateTime.utc(2026, 1, 2);
      // The page is committed only after every row in it is classified, so the
      // store cannot tell a first sight from a repeat inside the same page.
      await pump([
        [_message('m1', at), _message('m1', at)],
        [],
      ]);

      await container.read(chatGlobalSyncProvider.notifier).syncAllMessages();

      expect(summary()?.unreadCount, 1);
      expect(summary()?.lastMessage?.id, 'm1');
    });

    test('an older replayed message never moves the preview backwards',
        () async {
      final newer = _message('m2', DateTime.utc(2026, 1, 3));
      final older = _message('m1', DateTime.utc(2026, 1, 2));
      await pump([
        [newer],
        [],
      ]);

      final notifier = container.read(chatGlobalSyncProvider.notifier);
      await notifier.syncAllMessages();
      expect(summary()?.lastMessage?.id, 'm2');

      await container.read(chatSummaryProvider.notifier).applySyncedLastMessages(
        latestByRoom: {older.chatRoomId: older},
        newMessagesByRoom: {older.chatRoomId: [older]},
      );
      expect(summary()?.lastMessage?.id, 'm2');
    });

    test('the socket frame for a message the sync stored does not count twice',
        () async {
      final at = DateTime.utc(2026, 1, 2);
      final message = _message('m1', at);
      await pump([
        [message],
        [],
      ]);

      await container.read(chatGlobalSyncProvider.notifier).syncAllMessages();
      expect(summary()?.unreadCount, 1);

      // At-least-once delivery: the message also arrives as a frame, which the
      // summary's own socket listener folds by id.
      ws.push(message);
      await pumpEventQueue();

      expect(summary()?.unreadCount, 1);
      expect(summary()?.lastMessage?.id, 'm1');
    });

    test('a message the socket folded first is not counted again by sync',
        () async {
      final at = DateTime.utc(2026, 1, 2);
      final message = _message('m1', at);
      await pump([
        [message],
        [],
      ]);

      // The frame lands first, so the socket path folds it and claims the id.
      ws.push(message);
      await pumpEventQueue();
      expect(summary()?.unreadCount, 1);

      await container.read(chatGlobalSyncProvider.notifier).syncAllMessages();

      expect(summary()?.unreadCount, 1);
      expect(summary()?.lastMessage?.id, 'm1');
    });

    test('only history newer than the read marker raises the badge', () async {
      final sentAt = DateTime.utc(2026, 1, 2);
      // Read on another device after this message was sent.
      final member = _member(DateTime.utc(2026)).copyWith(
        lastReadAt: sentAt.add(const Duration(hours: 1)),
      );
      await pump(
        [
          [_message('m1', sentAt)],
          [],
        ],
        member: member,
      );

      await container.read(chatGlobalSyncProvider.notifier).syncAllMessages();

      expect(summary()?.lastMessage?.id, 'm1');
      expect(
        summary()?.unreadCount,
        0,
        reason: 'backfilled history the user has already read stays read',
      );
    });

    test('a message newer than the read marker counts once', () async {
      final sentAt = DateTime.utc(2026, 1, 2);
      final member = _member(DateTime.utc(2026)).copyWith(
        lastReadAt: sentAt.subtract(const Duration(hours: 1)),
      );
      await pump(
        [
          [_message('m1', sentAt)],
          [],
        ],
        member: member,
      );

      await container.read(chatGlobalSyncProvider.notifier).syncAllMessages();

      expect(summary()?.unreadCount, 1);
      expect(summary()?.hasUnread, isTrue);
    });
  });
}