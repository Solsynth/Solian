import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/chat/widgets/chat_list_screen.dart';
import 'package:island/chat/widgets/chat_room_list_tile.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/data/database.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/shared/widgets/page_app_bar.dart';
import 'package:island/shared/widgets/pill_surface.dart';
import 'package:island/shared/widgets/hover_horizontal_scroll_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Answers every request with an empty list: the page's providers reach for the
/// API on build, and a real client would leave dio's retry timers pending past
/// teardown.
class _EmptyAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(const <dynamic>[]),
      200,
      headers: {
        Headers.contentTypeHeader: const ['application/json'],
      },
    );
  }
}

SnChatRoom _room(
  String id,
  String name, {
  bool pinned = false,
  int type = 0,
  List<SnChatMember>? members,
}) {
  final now = DateTime.utc(2026);
  return SnChatRoom(
    id: id,
    name: name,
    description: null,
    type: type,
    picture: null,
    background: null,
    realmId: null,
    accountId: null,
    realm: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    members: members,
    isPinned: pinned,
  );
}

SnChatMember _member(SnAccount account) {
  final now = DateTime.utc(2026);
  return SnChatMember(
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    id: 'member-${account.id}',
    chatRoomId: 'dm',
    chatRoom: null,
    accountId: account.id,
    account: account,
    nick: null,
    notify: 0,
    joinedAt: now,
    breakUntil: null,
    timeoutUntil: null,
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

SnAccount _account(String id, String nick) {
  final now = DateTime.utc(2026);
  return SnAccount(
    id: id,
    name: id,
    nick: nick,
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
  );
}

/// The DM peer as the friends overview reports them: the status carries the
/// presence the badge paints.
SnFriendOverviewItem _friend(
  SnAccount account, {
  required bool isOnline,
  int type = SnAccountStatusType.defaultType,
}) {
  final now = DateTime.utc(2026);
  return SnFriendOverviewItem(
    account: account,
    status: SnAccountStatus(
      id: 'status-${account.id}',
      attitude: 0,
      isOnline: isOnline,
      type: type,
      isCustomized: false,
      meta: null,
      clearedAt: null,
      accountId: account.id,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    ),
    activities: const <SnPresenceActivity>[],
  );
}

class _JoinedRooms extends ChatRoomJoinedNotifier {
  _JoinedRooms(this.rooms);

  final List<SnChatRoom> rooms;

  @override
  Stream<List<SnChatRoom>> build() => Stream.value(rooms);
}

class _NoSummaries extends ChatSummary {
  @override
  Future<Map<String, SnChatSummary>> build() async => const {};
}

/// A signed-in shell: the list paints its rooms only for an account.
class _SignedIn extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async {
    final now = DateTime.utc(2026);
    return SnAccount(
      id: 'me',
      name: 'me',
      nick: 'Me',
      language: 'en',
      isSuperuser: false,
      automatedId: null,
      profile: SnAccountProfile(
        id: 'profile-me',
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
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpList(
    WidgetTester tester,
    Size size, {
    required List<SnChatRoom> rooms,
    List<SnFriendOverviewItem> friends = const <SnFriendOverviewItem>[],
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _EmptyAdapter();

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
                overrides: [
                  sharedPreferencesProvider.overrideWithValue(prefs),
                  databaseProvider.overrideWithValue(AppDatabase.web()),
                  apiClientProvider.overrideWithValue(dio),
                  chatRoomJoinedProvider.overrideWith(
                    () => _JoinedRooms(rooms),
                  ),
                  chatSummaryProvider.overrideWith(_NoSummaries.new),
                  userInfoProvider.overrideWith(_SignedIn.new),
                  // The chat list reads the compact overview while the explore
                  // strip reads the expanded one; both see the same friends.
                  friendsOverviewProvider.overrideWith((ref) async => friends),
                  friendsOverviewExpandedProvider.overrideWith(
                    (ref) async => friends,
                  ),
                ],
                child: const ChatListWidget(),
              ),
            ),
          ),
        ),
      );
      // EasyLocalization paints nothing until its asset bundle resolves, which
      // needs real time rather than the test clock.
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    while (tester.takeException() != null) {}
  }

  testWidgets('narrow: the rooms render under the split glass header', (
    tester,
  ) async {
    await pumpList(
      tester,
      const Size(400, 800),
      rooms: [_room('r1', 'Design crew'), _room('r2', 'Ops')],
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ChatRoomListTile), findsNWidgets(2));
    expect(find.text('Design crew'), findsOneWidget);
    // The portrait header is two separate glass surfaces: navigation and the
    // section picker both lead from the left.
    expect(find.byType(PillAppBar), findsNothing);
    expect(find.byType(GlassNavigationButton), findsOneWidget);
    final pills = find.byType(PillSurface);
    expect(pills, findsNWidgets(2));
    expect(
      tester.getSize(pills.at(0)).height,
      tester.getSize(pills.at(1)).height,
      reason: 'both portrait header controls share one row height',
    );
    // The switcher is the explore page's dropdown: one trigger naming the
    // current filter, and no leftover tab strip.
    expect(find.byType(TabBar), findsNothing);
    expect(find.byType(MenuAnchor), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    final navRect = tester.getRect(find.byType(GlassNavigationButton));
    final pickerRect = tester.getRect(find.byType(MenuAnchor));
    expect(pickerRect.left, greaterThan(navRect.right));
    expect(pickerRect.left, lessThan(200));
    expect(pickerRect.center.dy, closeTo(navRect.center.dy, 1));

    // The first room sits exactly under the split header's band.
    expect(
      tester.getTopLeft(find.byType(ChatRoomListTile).first).dy,
      closeTo(kPillSplitBarBand, 1),
    );

    await disposeTree(tester);
  });

  testWidgets('the switcher filters the list to one kind of room', (
    tester,
  ) async {
    await pumpList(
      tester,
      const Size(400, 800),
      rooms: [
        _room('g1', 'Design crew'),
        _room('d1', 'Nia', type: 1),
        _room('g2', 'Ops'),
      ],
    );

    // All: every room.
    expect(find.byType(ChatRoomListTile), findsNWidgets(3));

    // The menu animates, so settle it with the test clock rather than
    // pumpAndSettle: the page keeps a repeating sync timer that never idles.
    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.tap(find.text('All'));
    await settle();
    expect(find.byType(MenuItemButton), findsNWidgets(3));

    await tester.tap(find.widgetWithText(MenuItemButton, 'Group Chats'));
    await settle();

    // The menu closes and the list keeps only group rooms.
    expect(find.byType(MenuItemButton), findsNothing);
    expect(find.text('Group Chats'), findsOneWidget);
    expect(find.text('Design crew'), findsOneWidget);
    expect(find.text('Ops'), findsOneWidget);
    expect(find.text('Nia'), findsNothing);

    // Switching tabs schedules the room-list's debounced work; let those one
    // second timers expire before the tree goes away.
    await tester.pump(const Duration(seconds: 2));
    await disposeTree(tester);
  });

  testWidgets('a pinned room joins the quick strip and the list', (
    tester,
  ) async {
    await pumpList(
      tester,
      const Size(400, 800),
      rooms: [
        _room('p1', 'Pinned pal', pinned: true),
        _room('r1', 'Design crew'),
      ],
    );

    expect(tester.takeException(), isNull);
    // The pinned room is quick access only: both rooms still occupy the list.
    expect(find.byType(ChatRoomListTile), findsNWidgets(2));
    expect(find.text('Pinned pal'), findsNWidgets(2));

    // The strip borrows the explore feed's gutter and tile height but not its
    // floating card: the list is already one surface, so the avatars sit on
    // it and no rule separates them from the rooms below.
    final strip = find.byType(HoverHorizontalScrollList);
    expect(strip, findsOneWidget);
    expect(tester.getSize(strip).height, closeTo(84, 1));
    expect(find.byType(ExploreCard), findsNothing);
    expect(find.byType(Divider), findsNothing);

    await disposeTree(tester);
  });

  testWidgets('an online DM paints the explore presence badge', (
    tester,
  ) async {
    final nia = _account('nia', 'Nia');
    await pumpList(
      tester,
      const Size(400, 800),
      rooms: [_room('d1', 'Nia', type: 1, members: [_member(nia)])],
      // A busy friend: the badge must follow the status colour, not paint a
      // fixed green dot the way the pinned tile used to.
      friends: [_friend(nia, isOnline: true, type: SnAccountStatusType.busy)],
    );

    expect(tester.takeException(), isNull);
    // The online DM auto-joins the quick strip, so both the pinned tile and
    // the list row carry the badge.
    expect(find.text('Nia'), findsNWidgets(2));
    final badges = find.byType(FriendPresenceBadge);
    expect(badges, findsNWidgets(2));
    for (final badge in tester.widgetList<FriendPresenceBadge>(badges)) {
      expect(badge.friend.account.id, 'nia');
    }
    for (var i = 0; i < 2; i++) {
      final dot = tester.widget<Container>(
        find.descendant(of: badges.at(i), matching: find.byType(Container)),
      );
      expect(
        (dot.decoration as BoxDecoration).color,
        Colors.orange,
        reason: 'busy friends read orange in explore, so chat must agree',
      );
    }

    await disposeTree(tester);
  });

  testWidgets('an offline DM paints no presence badge', (tester) async {
    final nia = _account('nia', 'Nia');
    await pumpList(
      tester,
      const Size(400, 800),
      rooms: [_room('d1', 'Nia', type: 1, members: [_member(nia)])],
      friends: [_friend(nia, isOnline: false)],
    );

    expect(tester.takeException(), isNull);
    // Offline: no quick-strip entry, no sprite on the row.
    expect(find.text('Nia'), findsOneWidget);
    expect(find.byType(FriendPresenceBadge), findsNothing);

    await disposeTree(tester);
  });

  testWidgets('wide: the picker leads the pane while the controls float', (
    tester,
  ) async {
    await pumpList(
      tester,
      const Size(1400, 900),
      rooms: [_room('r1', 'Design crew'), _room('r2', 'Ops')],
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ChatRoomListTile), findsNWidgets(2));
    // The pane carries no "Chat" title any more: the section picker takes the
    // leading slot of the floating band.
    expect(find.byType(PillAppBar), findsNothing);
    expect(find.text('Chat'), findsNothing);
    expect(find.byType(PillSurface), findsNWidgets(2));
    expect(find.byType(BackdropFilter), findsNothing);
    // The three-way switcher is the explore page's dropdown, not a tab strip.
    expect(find.byType(TabBar), findsNothing);
    expect(find.byType(MenuAnchor), findsOneWidget);

    // Navigation toggle first, then the picker: both lead the pane's row
    // instead of the picker sitting flush right.
    final navLeft = tester.getTopLeft(find.byType(GlassNavigationButton)).dx;
    final pickerLeft = tester.getTopLeft(find.byType(MenuAnchor)).dx;
    expect(pickerLeft, greaterThan(navLeft));
    expect(pickerLeft, lessThan(400));
    expect(
      tester.getCenter(find.byType(MenuAnchor)).dy,
      closeTo(tester.getCenter(find.byType(GlassNavigationButton)).dy, 1),
    );
    expect(
      tester.getTopLeft(find.byType(ChatRoomListTile).first).dy,
      closeTo(kPillSplitBarBand, 1),
    );

    // The pane no longer paints a card surface of its own: only the header
    // pills carry a surface, and the list floats on the page background.
    expect(
      find.descendant(
        of: find.byType(ChatListWidget),
        matching: find.byType(Card),
      ),
      findsNothing,
    );

    await disposeTree(tester);
  });
}
