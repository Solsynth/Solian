import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/data/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _SignedOutUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

class _FakeWebSocketService extends SolarWebSocketService {
  _FakeWebSocketService() : super(uri: () => Uri(), token: () async => null);

  @override
  Stream<WebSocketPacket> get dataStream => const Stream.empty();
}

/// Holds the rooms sync request in flight so the provider can be disposed
/// mid-sync, the way leaving or refreshing the chat list does.
class _BlockingRoomSyncAdapter implements HttpClientAdapter {
  final Completer<void> syncStarted = Completer<void>();
  final Completer<void> release = Completer<void>();

  @override
  void close({bool force = false}) {}

  static ResponseBody _json(String body) => ResponseBody.fromString(
    body,
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async {
    if (!options.path.endsWith('/messager/chat/rooms/sync')) {
      return _json('[]');
    }
    if (!syncStarted.isCompleted) syncStarted.complete();
    await release.future;
    return _json(
      '{"changes":[],"summaries":[],"groups":[],"current_timestamp":0}',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a rooms sync cut short by disposal still clears the sync flag',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final database = AppDatabase.web();
    final adapter = _BlockingRoomSyncAdapter();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        databaseProvider.overrideWithValue(database),
        sharedPreferencesProvider.overrideWithValue(prefs),
        tokenProvider.overrideWithValue(null),
        apiClientProvider.overrideWithValue(
          Dio()..httpClientAdapter = adapter,
        ),
        userInfoProvider.overrideWith(_SignedOutUserInfo.new),
        websocketProvider.overrideWithValue(_FakeWebSocketService()),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    final subscription = container.listen(chatRoomJoinedProvider, (_, _) {});
    await adapter.syncStarted.future;
    expect(container.read(chatSyncingProvider), isTrue);

    // The room list dropped its listener while the request was in flight, so
    // the auto-dispose provider is torn down before the sync finishes.
    subscription.close();
    await pumpEventQueue();

    adapter.release.complete();
    await pumpEventQueue();

    expect(container.read(chatSyncingProvider), isFalse);
  });
}
