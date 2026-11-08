import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_room_state.dart';
import 'package:island/chat/widgets/room_message_list.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/data/database.dart';
import 'package:island/data/message.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// The "new messages" rule and the "messages skipped" seam belong to the
/// message they precede, and they end the run of bubbles they land in.
///
/// A sender group renders every bubble of that sender from a single list item,
/// so a boundary inside a run must place its marker on the bubble itself (not
/// on the item, which would drop it) and split the run, so the reader gets a
/// fresh sender header on the far side instead of one connected block of
/// bubbles with a seam punched through it.
class _EmptyResponseAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions _,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async => ResponseBody.fromString(
    '{}',
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

class _FakeWebSocketService extends SolarWebSocketService {
  _FakeWebSocketService() : super(uri: () => Uri(), token: () async => null);

  final _controller = StreamController<WebSocketPacket>.broadcast();

  @override
  Stream<WebSocketPacket> get dataStream => _controller.stream;
}

class _FakeMessagesNotifier extends MessagesNotifier {
  @override
  FutureOr<List<LocalChatMessage>> build(String roomId) => const [];

  @override
  Future<void> loadMore({int? offset}) async {}

  @override
  Future<void> loadMoreBeforeOldest() async {}

  @override
  Future<MessageLoadGap?> compactForOlderScroll({
    int retainedMessagesPerSection = 100,
  }) async => null;
}

class _FakeRoomNotifier extends ChatRoomNotifier {
  @override
  Future<SnChatRoom?> build(String? identifier) async => null;
}

class _FakeIdentityNotifier extends ChatRoomIdentityNotifier {
  @override
  Future<SnChatMember?> build(String? identifier) async => null;
}

SnChatMember _member(String id) {
  final now = DateTime.utc(2026);
  return SnChatMember(
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    id: 'member-$id',
    chatRoomId: 'room-1',
    chatRoom: null,
    accountId: id,
    account: SnAccount(
      id: id,
      name: id,
      nick: id,
      language: 'en',
      isSuperuser: false,
      automatedId: null,
      profile: SnAccountProfile(
        id: 'profile-$id',
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
}

LocalChatMessage _message(String id, String senderId, DateTime at) {
  return LocalChatMessage.fromRemoteMessage(
    SnChatMessage(
      createdAt: at,
      updatedAt: at,
      id: id,
      content: 'hello from $id',
      type: 'text',
      senderId: senderId,
      sender: _member(senderId),
      chatRoomId: 'room-1',
    ),
    MessageStatus.sent,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late _FakeWebSocketService ws;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() async {
    database = AppDatabase.web();
    ws = _FakeWebSocketService();
  });

  tearDown(() async {
    await database.close();
    await ws._controller.close();
  });

  for (final displayStyle in ['bubble', 'column']) {
    testWidgets(
      'markers land on their message and end the sender run ($displayStyle)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(420, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SharedPreferences.setMockInitialValues({
          kAppMessageDisplayStyle: displayStyle,
        });
        final preferences = await SharedPreferences.getInstance();

        final base = DateTime.utc(2026, 1, 1, 12);
        // Newest first. Three senders, each a group of six.
        final messages = <LocalChatMessage>[];
        for (final sender in ['bob', 'alice', 'carol']) {
          final prefix = sender[0];
          final start = sender == 'bob'
              ? 0
              : sender == 'alice'
              ? 20
              : 40;
          for (var i = 0; i < 6; i++) {
            messages.add(
              _message(
                '$prefix$i',
                sender,
                base.subtract(Duration(minutes: start + i)),
              ),
            );
          }
        }

        await tester.runAsync(() async {
          await tester.pumpWidget(
            EasyLocalization(
              supportedLocales: const [Locale('en', 'US')],
              path: 'assets/i18n',
              saveLocale: false,
              child: Builder(
                builder: (context) => MaterialApp(
                  locale: const Locale('en', 'US'),
                  supportedLocales: const [Locale('en', 'US')],
                  localizationsDelegates: context.localizationDelegates,
                  home: ProviderScope(
                    retry: (_, _) => null,
                    overrides: [
                      databaseProvider.overrideWithValue(database),
                      sharedPreferencesProvider.overrideWithValue(preferences),
                      tokenProvider.overrideWithValue(null),
                      apiClientProvider.overrideWithValue(
                        Dio()..httpClientAdapter = _EmptyResponseAdapter(),
                      ),
                      websocketProvider.overrideWithValue(ws),
                      messagesProvider(
                        'room-1',
                      ).overrideWith(() => _FakeMessagesNotifier()),
                      chatRoomProvider(
                        'room-1',
                      ).overrideWith(() => _FakeRoomNotifier()),
                      chatRoomIdentityProvider(
                        'room-1',
                      ).overrideWith(() => _FakeIdentityNotifier()),
                    ],
                    child: Scaffold(
                      body: RoomMessageList(
                        roomId: 'room-1',
                        messages: messages,
                        roomAsync: const AsyncValue.data(null),
                        chatIdentity: const AsyncValue.data(null),
                        onJump: (_) {},
                        onLoadMessageGap: (_) async {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 200));
        });
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        final container = ProviderScope.containerOf(
          tester.element(find.byType(RoomMessageList)),
        );
        final notifier = container.read(
          chatRoomStateProvider('room-1').notifier,
        );

        // Both boundaries fall inside a sender group, on a middle bubble.
        notifier.setLastReadAnchorMessageId('a2');
        notifier.updateMessageLoadGap(
          const MessageLoadGap(newerMessageId: 'b2', olderMessageId: 'b3'),
        );
        await tester.pumpAndSettle();

        final readMarker = find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_LastReadMarker',
        );
        final gapMarker = find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_MessageLoadGapMarker',
        );

        expect(readMarker, findsOneWidget);
        expect(gapMarker, findsOneWidget);

        // Each seam ends the run of bubbles it was dropped into: the nearer
        // side starts a fresh sender group (its own header and avatar), so a
        // rule never cuts through one connected block of bubbles. Group items
        // are keyed by their newest message.
        for (final groupKey in [
          'sticky-group-a0', // alice above the rule
          'sticky-group-a3', // alice below the rule
          'sticky-group-b0', // bob above the gap seam
          'sticky-group-b3', // bob below the gap seam
          'sticky-group-c0', // untouched run stays whole
        ]) {
          expect(
            find.byKey(ValueKey(groupKey)),
            findsOneWidget,
            reason: '$groupKey must be rendered as a group of its own',
          );
        }

        void expectSitsAbove(Finder marker, String anchorId) {
          final markerRect = tester.getRect(marker);
          final anchorText = tester.getRect(find.text('hello from $anchorId'));
          final olderIndex = int.parse(anchorId.substring(1)) + 1;
          final olderText = tester.getRect(
            find.text('hello from ${anchorId[0]}$olderIndex'),
          );

          expect(
            markerRect.height,
            greaterThan(0),
            reason: 'the marker must take space, not collapse',
          );
          // Directly above its own message, below the older one: neither
          // swallowed by the group nor attached to a neighbour.
          expect(markerRect.bottom, lessThanOrEqualTo(anchorText.top + 0.01));
          expect(
            markerRect.bottom,
            greaterThan(anchorText.top - 60),
            reason: 'the marker belongs to $anchorId, not to an older bubble',
          );
          expect(olderText.bottom, lessThanOrEqualTo(markerRect.top + 0.01));
        }

        expectSitsAbove(readMarker, 'a2');
        expectSitsAbove(gapMarker, 'b2');

        // The reported case: the boundary lands on the newest bubble of a run.
        // That bubble is then a message of its own — it draws its own avatar
        // and header below the rule instead of looking like a group member
        // while the rule cuts the group in half.
        notifier.setLastReadAnchorMessageId('a0');
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('sticky-group-a0')), findsNothing);
        expect(find.byKey(const ValueKey('sticky-group-a1')), findsOneWidget);

        final ruleRect = tester.getRect(readMarker);
        final anchorText = tester.getRect(find.text('hello from a0'));
        final avatars = tester.renderObjectList<RenderBox>(
          find.byType(ProfilePictureWidget),
        );
        final belowRule = avatars.where((box) {
          final top = box.localToGlobal(Offset.zero).dy;
          return top >= ruleRect.bottom - 1 && top <= anchorText.top;
        });
        expect(
          belowRule,
          isNotEmpty,
          reason: 'the first unread carries its own avatar below the rule',
        );
      },
    );
  }
}
