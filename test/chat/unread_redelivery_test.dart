import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/database.dart';
import 'package:island/core/websocket.dart';
import 'package:island/notifications/notification.dart';
import 'package:island/data/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A websocket service the test pushes frames into directly.
class _FakeWebSocketService extends SolarWebSocketService {
  _FakeWebSocketService() : super(uri: () => Uri(), token: () async => null);

  final _controller = StreamController<WebSocketPacket>.broadcast();

  @override
  Stream<WebSocketPacket> get dataStream => _controller.stream;

  void push(Map<String, dynamic> json) =>
      _controller.add(WebSocketPacket.fromJson(json));
}

/// Answers the unread REST calls with zero without touching the network.
class _UnreadAdapter implements HttpClientAdapter {
  _UnreadAdapter(this.body);

  final String body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions _,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async => ResponseBody.fromString(
    body,
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

/// Serves a room summary with nothing unread, for the per-room tile state.
class _SummaryAdapter implements HttpClientAdapter {
  _SummaryAdapter(this.roomId);

  final String roomId;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions _,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async => ResponseBody.fromString(
    jsonEncode({
      roomId: {'unread_count': 0, 'has_unread': false, 'last_message': null},
    }),
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

class _SignedOutUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

/// Signed in as `account-1`, the account the member rows belong to.
class _SignedInUserInfo extends UserInfoNotifier {
  _SignedInUserInfo(this._account);

  final SnAccount _account;

  @override
  Future<SnAccount?> build() async => _account;
}

final SnAccount _selfAccount = SnAccount(
  id: 'account-1',
  name: 'me',
  nick: 'Me',
  language: 'en',
  isSuperuser: false,
  automatedId: null,
  profile: SnAccountProfile(
    id: 'profile-self',
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
);

/// The current account's row in [roomId], carrying the room's notify level.
SnChatMember _selfMember(String roomId, {required int notify}) {
  final now = DateTime.utc(2026);
  return SnChatMember(
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    id: 'self-$roomId',
    chatRoomId: roomId,
    chatRoom: null,
    accountId: 'account-1',
    account: _selfAccount,
    nick: null,
    notify: notify,
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

Map<String, dynamic> _newMessageFrame(
  String id,
  String roomId, {
  List<String> mentions = const [],
}) {
  final now = DateTime.utc(2026);
  final member = SnChatMember(
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    id: 'member-$roomId',
    chatRoomId: roomId,
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
  return {
    'type': 'messages.new',
    'data': SnChatMessage(
      createdAt: now,
      updatedAt: now,
      id: id,
      content: 'hello',
      senderId: member.id,
      sender: member,
      membersMentioned: mentions,
      chatRoomId: roomId,
    ).toJson(),
    '_ack_id': 'ack-$id',
  };
}

Map<String, dynamic> _notificationFrame(String id) {
  final now = DateTime.utc(2026);
  return {
    'type': 'notifications.new',
    'data': SnNotification(
      id: id,
      appId: 'app-1',
      topic: 'posts.reply',
      title: 'Reply',
      subtitle: '',
      body: 'hi',
      createdAt: now,
      viewedAt: null,
      accountId: 'account-1',
    ).toJson(),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatUnreadCountNotifier re-delivery', () {
    late ProviderContainer container;
    late _FakeWebSocketService ws;
    late ProviderSubscription<AsyncValue<int>> subscription;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      ws = _FakeWebSocketService();
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenProvider.overrideWithValue(null),
          websocketProvider.overrideWithValue(ws),
          userInfoProvider.overrideWith(_SignedOutUserInfo.new),
          currentSubscribedChatIdProvider.overrideWith(
            _NoSubscribedRoomNotifier.new,
          ),
          apiClientProvider.overrideWithValue(
            Dio()..httpClientAdapter = _UnreadAdapter('0'),
          ),
        ],
      );
      // Keep the auto-disposed notifier alive for the pushed frames.
      subscription = container.listen(
        chatUnreadCountProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(() {
        subscription.close();
        container.dispose();
      });
      await container.read(chatUnreadCountProvider.future);
    });

    test('a repeated frame does not count twice', () async {
      ws.push(_newMessageFrame('m1', 'room-1'));
      await _settle(
        () => _unread(container.read(chatUnreadCountProvider)) == 1,
      );

      // The gateway re-sends until acked, so the same message arrives again.
      ws.push(_newMessageFrame('m1', 'room-1'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(_unread(container.read(chatUnreadCountProvider)), 1);

      // A genuinely new message still counts.
      ws.push(_newMessageFrame('m2', 'room-1'));
      await _settle(
        () => _unread(container.read(chatUnreadCountProvider)) == 2,
      );
    });
  });

  group('ChatUnreadCountNotifier room notify level', () {
    late ProviderContainer container;
    late _FakeWebSocketService ws;
    late AppDatabase database;
    late ProviderSubscription<AsyncValue<int>> subscription;

    /// Starts the notifier signed in with [member] stored, so the frame's room
    /// resolves to a notify level.
    Future<void> pump(SnChatMember member) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      ws = _FakeWebSocketService();
      database = AppDatabase.web();
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          databaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenProvider.overrideWithValue(null),
          websocketProvider.overrideWithValue(ws),
          userInfoProvider.overrideWith(
            () => _SignedInUserInfo(_selfAccount),
          ),
          currentSubscribedChatIdProvider.overrideWith(
            _NoSubscribedRoomNotifier.new,
          ),
          apiClientProvider.overrideWithValue(
            Dio()..httpClientAdapter = _UnreadAdapter('0'),
          ),
        ],
      );
      addTearDown(() async {
        subscription.close();
        container.dispose();
        await database.close();
      });
      await database.saveMember(member);
      subscription = container.listen(
        chatUnreadCountProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await container.read(chatUnreadCountProvider.future);
    }

    test('a mentions-only room counts a mention', () async {
      await pump(_selfMember('room-1', notify: 1));

      ws.push(
        _newMessageFrame('m1', 'room-1', mentions: const ['account-1']),
      );

      await _settle(
        () => _unread(container.read(chatUnreadCountProvider)) == 1,
      );
    });

    test('a mentions-only room ignores a plain message', () async {
      await pump(_selfMember('room-1', notify: 1));

      ws.push(_newMessageFrame('m1', 'room-1'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(_unread(container.read(chatUnreadCountProvider)), 0);

      // A later mention in the same room still raises the badge.
      ws.push(
        _newMessageFrame('m2', 'room-1', mentions: const ['account-1']),
      );
      await _settle(
        () => _unread(container.read(chatUnreadCountProvider)) == 1,
      );
    });

    test('a muted room never counts', () async {
      await pump(_selfMember('room-1', notify: 2));

      ws.push(
        _newMessageFrame('m1', 'room-1', mentions: const ['account-1']),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(_unread(container.read(chatUnreadCountProvider)), 0);
    });

    test('an all-messages room counts every message', () async {
      await pump(_selfMember('room-1', notify: 0));

      ws.push(_newMessageFrame('m1', 'room-1'));

      await _settle(
        () => _unread(container.read(chatUnreadCountProvider)) == 1,
      );
    });
  });

  group('ChatSummary room notify level', () {
    late ProviderContainer container;
    late _FakeWebSocketService ws;
    late AppDatabase database;
    late ProviderSubscription<AsyncValue<Map<String, SnChatSummary>>> sub;

    /// Starts the summary signed in with [member] stored, so the frame's room
    /// resolves to a notify level.
    Future<void> pump(SnChatMember member) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      ws = _FakeWebSocketService();
      database = AppDatabase.web();
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          databaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenProvider.overrideWithValue(null),
          websocketProvider.overrideWithValue(ws),
          userInfoProvider.overrideWith(
            () => _SignedInUserInfo(_selfAccount),
          ),
          currentSubscribedChatIdProvider.overrideWith(
            _NoSubscribedRoomNotifier.new,
          ),
          apiClientProvider.overrideWithValue(
            Dio()..httpClientAdapter = _SummaryAdapter('room-1'),
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
      });
      await database.saveMember(member);
      sub = container.listen(
        chatSummaryProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);
      await container.read(chatSummaryProvider.future);
    }

    SnChatSummary? summary() =>
        container.read(chatSummaryProvider).value?['room-1'];

    Future<void> pushFrame(Map<String, dynamic> frame) async {
      ws.push(frame);
      await pumpEventQueue();
    }

    test('a mentions-only room counts only its mentions', () async {
      await pump(_selfMember('room-1', notify: 1));

      await pushFrame(_newMessageFrame('m1', 'room-1'));
      expect(summary()?.unreadCount, 0);
      expect(
        summary()?.hasUnread,
        isTrue,
        reason: 'plain chatter still leaves the room unread',
      );

      await pushFrame(
        _newMessageFrame('m2', 'room-1', mentions: const ['account-1']),
      );
      expect(summary()?.unreadCount, 1, reason: 'only the mention counts');
      expect(summary()?.hasUnread, isTrue);
    });

    test('a muted room counts nothing but is still marked unread', () async {
      await pump(_selfMember('room-1', notify: 2));

      await pushFrame(
        _newMessageFrame('m1', 'room-1', mentions: const ['account-1']),
      );

      expect(summary()?.unreadCount, 0);
      // The server computes `has_unread` before it applies the notify level, so
      // a muted room still carries the dot. Mirroring that keeps the tile from
      // flipping when the next rooms sync replaces this summary.
      expect(summary()?.hasUnread, isTrue);
    });

    test('an all-messages room counts every message', () async {
      await pump(_selfMember('room-1', notify: 0));

      await pushFrame(_newMessageFrame('m1', 'room-1'));
      await pushFrame(_newMessageFrame('m2', 'room-1'));

      expect(summary()?.unreadCount, 2);
      expect(summary()?.hasUnread, isTrue);
    });

    test('a mutation envelope neither counts nor replaces the preview',
        () async {
      await pump(_selfMember('room-1', notify: 0));

      await pushFrame(_newMessageFrame('m1', 'room-1'));
      expect(summary()?.lastMessage?.id, 'm1');

      final edit = _newMessageFrame('e1', 'room-1');
      final data = Map<String, dynamic>.from(edit['data'] as Map);
      data['type'] = 'messages.update';
      data['meta'] = {'message_id': 'm1'};
      await pushFrame({'type': 'messages.new', 'data': data});

      expect(
        summary()?.unreadCount,
        1,
        reason: 'an edit event is not a new message',
      );
      expect(
        summary()?.lastMessage?.id,
        'm1',
        reason: 'the edit only refreshes the preview of m1',
      );
    });

    test('a re-delivered frame counts once', () async {
      await pump(_selfMember('room-1', notify: 0));

      await pushFrame(_newMessageFrame('m1', 'room-1'));
      await pushFrame(_newMessageFrame('m1', 'room-1'));

      expect(summary()?.unreadCount, 1);
    });

    test('the open room never raises its own unread state', () async {
      await pump(_selfMember('room-1', notify: 0));
      container
          .read(currentSubscribedChatIdProvider.notifier)
          .set('room-1');

      await pushFrame(_newMessageFrame('m1', 'room-1'));

      expect(summary()?.unreadCount, 0);
      expect(summary()?.hasUnread, isFalse);
      expect(
        summary()?.lastMessage?.id,
        'm1',
        reason: 'the preview still follows the open room',
      );
    });
  });

  group('NotificationUnreadCountNotifier re-delivery', () {
    late ProviderContainer container;
    late _FakeWebSocketService ws;
    late ProviderSubscription<AsyncValue<int>> subscription;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      ws = _FakeWebSocketService();
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenProvider.overrideWithValue(null),
          websocketProvider.overrideWithValue(ws),
          userInfoProvider.overrideWith(_SignedOutUserInfo.new),
          apiClientProvider.overrideWithValue(
            Dio()..httpClientAdapter = _UnreadAdapter('0'),
          ),
        ],
      );
      subscription = container.listen(
        notificationUnreadCountProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(() {
        subscription.close();
        container.dispose();
      });
      await container.read(notificationUnreadCountProvider.future);
    });

    test('a repeated notification does not count twice', () async {
      ws.push(_notificationFrame('n1'));
      await _settle(
        () => _unread(container.read(notificationUnreadCountProvider)) == 1,
      );

      ws.push(_notificationFrame('n1'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(_unread(container.read(notificationUnreadCountProvider)), 1);

      ws.push(_notificationFrame('n2'));
      await _settle(
        () => _unread(container.read(notificationUnreadCountProvider)) == 2,
      );
    });
  });
}

class _NoSubscribedRoomNotifier extends CurrentSubscribedChatIdNotifier {
  @override
  String? build() => null;
}

int _unread(AsyncValue<int> value) =>
    value.maybeWhen(data: (count) => count, orElse: () => -1);

Future<void> _settle(bool Function() until) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    if (until()) return;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('condition not reached');
}
