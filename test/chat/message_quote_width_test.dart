import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/chat/widgets/message_item.dart';
import 'package:island/core/config.dart';
import 'package:island/data/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _FixedReferencedCache extends ReferencedChatMessageCache {
  final Map<String, AsyncValue<LocalChatMessage?>> initial;

  _FixedReferencedCache(super.arg, this.initial);

  @override
  Map<String, AsyncValue<LocalChatMessage?>> build() => initial;
}

SnChatMember _testMember() {
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
    nick: 'Test',
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

LocalChatMessage _testMessage({
  required String id,
  required String content,
  String? repliedMessageId,
}) {
  final now = DateTime.utc(2026);
  final sender = _testMember();
  return LocalChatMessage.fromRemoteMessage(
    SnChatMessage(
      createdAt: now,
      updatedAt: now,
      id: id,
      content: content,
      senderId: sender.id,
      sender: sender,
      chatRoomId: 'room-1',
      repliedMessageId: repliedMessageId,
    ),
    MessageStatus.sent,
  );
}

void main() {
  testWidgets(
    'MessageItemDisplayBubble stretches quote band to body width without expanding bubble',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      final quoted = _testMessage(id: 'quoted-1', content: 'hi');
      final reply = _testMessage(
        id: 'reply-1',
        content: 'Hello world',
        repliedMessageId: 'quoted-1',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            userInfoProvider.overrideWithBuild((ref, _) => null),
            referencedChatMessageCacheProvider('room-1').overrideWith(
              () => _FixedReferencedCache('room-1', {
                'quoted-1': AsyncData(quoted),
              }),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: MessageItemDisplayBubble(
                message: reply,
                isCurrentUser: false,
                progress: null,
                showAvatar: false,
                showBubbleAvatar: false,
                isFirstInGroup: true,
                isLastInGroup: true,
                onJump: (_) {},
                translatedText: null,
                translating: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final quoteSize = tester.getSize(find.byType(MessageQuoteWidget));
      // Find the bubble's decorated Container (parent of _BubbleColumn).
      final bubbleContainerFinder = find.ancestor(
        of: find.byType(MessageQuoteWidget),
        matching: find.byType(Container),
      );
      final bubbleSize = tester.getSize(bubbleContainerFinder.first);

      expect(quoteSize.width, equals(bubbleSize.width));
      // Must not stretch to the full 600px viewport width.
      expect(bubbleSize.width, lessThan(500));
    },
  );
}
