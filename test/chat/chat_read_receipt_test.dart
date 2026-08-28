import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:island/chat/widgets/message_indicators.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/data/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Counts how many times the room/identity provider rebuilds so the test can
/// assert that a read receipt does NOT refetch them (the pre-fix behavior
/// invalidated both, which bounced the whole ChatRoomScreen through its
/// loading branch every few seconds).
class _TrackingChatRoomNotifier extends ChatRoomNotifier {
  int buildCount = 0;

  @override
  Future<SnChatRoom?> build(String? identifier) async {
    buildCount++;
    return null;
  }
}

class _TrackingChatRoomIdentityNotifier extends ChatRoomIdentityNotifier {
  int buildCount = 0;

  @override
  Future<SnChatMember?> build(String? identifier) async {
    buildCount++;
    return null;
  }
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

/// A fake WebSocket service whose data stream the test can drive directly.
class _FakeWebSocketService extends WebSocketService {
  final _controller = StreamController<WebSocketPacket>.broadcast();

  @override
  Stream<WebSocketPacket> get dataStream => _controller.stream;

  void emit(WebSocketPacket packet) => _controller.add(packet);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('read receipts', () {
    late AppDatabase database;
    late ProviderContainer container;
    late _FakeWebSocketService ws;
    late _TrackingChatRoomNotifier roomNotifier;
    late _TrackingChatRoomIdentityNotifier identityNotifier;

    setUp(() async {
      database = AppDatabase.web();
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      ws = _FakeWebSocketService();
      roomNotifier = _TrackingChatRoomNotifier();
      identityNotifier = _TrackingChatRoomIdentityNotifier();

      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          databaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(preferences),
          tokenProvider.overrideWithValue(null),
          apiClientProvider.overrideWithValue(
            Dio()..httpClientAdapter = _EmptyResponseAdapter(),
          ),
          websocketProvider.overrideWithValue(ws),
          chatRoomProvider('room-1').overrideWith(() => roomNotifier),
          chatRoomIdentityProvider(
            'room-1',
          ).overrideWith(() => identityNotifier),
        ],
      );

      // Activate the read-receipt handler.
      container.read(chatReadSyncProvider);
    });

    tearDown(() async {
      container.dispose();
      await database.close();
      await ws._controller.close();
    });

    test(
      'does not rebuild room or identity providers on a read receipt',
      () async {
        // Seed a member row so the handler persists the new lastReadAt.
        final now = DateTime.utc(2026, 8, 25, 8);
        final account = SnAccount(
          id: 'account-1',
          name: 'peer',
          nick: 'Peer',
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
        );
        final member = SnChatMember(
          createdAt: now,
          updatedAt: now,
          deletedAt: null,
          id: 'member-1',
          chatRoomId: 'room-1',
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
        await database.saveMember(member);

        // Warm the providers so the read receipt has a baseline build count.
        container.listen(chatRoomProvider('room-1'), (_, _) {});
        container.listen(chatRoomIdentityProvider('room-1'), (_, _) {});
        container.listen(roomReadStateProvider('room-1'), (_, _) {});
        await container.read(chatRoomProvider('room-1').future);
        await container.read(chatRoomIdentityProvider('room-1').future);
        await container.read(roomReadStateProvider('room-1').future);

        final roomBuildsBefore = roomNotifier.buildCount;
        final identityBuildsBefore = identityNotifier.buildCount;

        // The peer reads the room; the server broadcasts the receipt to every
        // member (including us). This is the packet that used to invalidate
        // both providers and bounce the whole screen.
        ws.emit(
          WebSocketPacket(
            type: 'messages.read',
            data: {
              'chat_room_id': 'room-1',
              'account_id': account.id,
              'member_id': member.id,
              'last_read_at': now.add(const Duration(minutes: 5)).toIso8601String(),
            },
            endpoint: 'messager',
          ),
        );

        // Let the async handler run.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await container.read(roomReadStateProvider('room-1').future);

        expect(
          roomNotifier.buildCount,
          roomBuildsBefore,
          reason: 'read receipt must not refetch the room provider',
        );
        expect(
          identityNotifier.buildCount,
          identityBuildsBefore,
          reason: 'read receipt must not refetch the identity provider',
        );
      },
    );
  });
}
