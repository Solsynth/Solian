import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/message_content.dart';
import 'package:island/core/config.dart';
import 'package:island/data/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnChatMember _member() {
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
    id: 'member-room-1',
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
}

SnChatMessage _message({String? content}) {
  final now = DateTime.utc(2026);
  final sender = _member();
  return SnChatMessage(
    createdAt: now,
    updatedAt: now,
    id: 'message-1',
    content: content,
    senderId: sender.id,
    sender: sender,
    chatRoomId: 'room-1',
  );
}

Future<void> _pumpContent(WidgetTester tester, SnChatMessage item) async {
  final preferences = await SharedPreferences.getInstance();
  await tester.runAsync(() async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('zh', 'CN')],
        path: 'assets/i18n',
        saveLocale: false,
        child: Builder(
          builder: (context) => MaterialApp(
            locale: const Locale('zh', 'CN'),
            supportedLocales: const [Locale('zh', 'CN')],
            localizationsDelegates: context.localizationDelegates,
            home: ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(preferences),
              ],
              child: Scaffold(body: MessageContent(item: item)),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  test('a remote deletion keeps the mark and stays renderable', () {
    final remote = _message(
      content: null,
    ).copyWith(deletedAt: DateTime.utc(2026, 3));
    final local = LocalChatMessage.fromRemoteMessage(
      remote,
      MessageStatus.sent,
    );

    expect(local.deletedAt, DateTime.utc(2026, 3));
    expect(local.isDeleted, isTrue);
    // The tombstone has no body, yet its row still has to lay out.
    expect(MessageContent.hasContent(remote), isTrue);
  });

  testWidgets('a deleted message renders the marker instead of its body', (
    tester,
  ) async {
    final deleted = _message(
      content: 'RAW PAYLOAD TEXT',
    ).copyWith(deletedAt: DateTime.utc(2026, 2));

    await _pumpContent(tester, deleted);

    // The marker is client-side and localized: whatever placeholder the payload
    // still carries must never reach the timeline.
    expect(find.text('此消息已被删除'), findsOneWidget);
    expect(find.text('RAW PAYLOAD TEXT'), findsNothing);
  });

  testWidgets('a deletion event renders the localized action label', (
    tester,
  ) async {
    final event = _message(content: 'RAW EVENT TEXT').copyWith(
      type: 'messages.delete',
      meta: const {'message_id': 'message-1'},
    );

    await _pumpContent(tester, event);

    expect(find.text('删除了一条消息'), findsOneWidget);
    expect(find.text('RAW EVENT TEXT'), findsNothing);
  });
}
