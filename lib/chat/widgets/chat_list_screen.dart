import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/shared/hooks/material_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/relationship_pod.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/chat/pods/chat_account_status.dart';
import 'package:island/chat/pods/chat_foreground_rooms.dart';
import 'package:island/chat/pods/chat_outbox.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/chat/utils/chat_room_ordering.dart';
import 'package:island/chat/widgets/chat_groups_manager.dart';
import 'package:island/chat/widgets/chat_invites_sheet.dart';
import 'package:island/chat/widgets/chat_room_form.dart';
import 'package:island/chat/widgets/chat_room_list_tile.dart';
import 'package:island/chat/widgets/chat_room_widgets.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/lifecycle.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/data/database.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/page_app_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/hover_horizontal_scroll_list.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _CustomChatGroupSection {
  const _CustomChatGroupSection({required this.group, required this.rooms});

  final SnChatGroup group;
  final List<SnChatRoom> rooms;
}

class _RealmChatGroupSection {
  const _RealmChatGroupSection({required this.realm, required this.rooms});

  final SnRealm? realm;
  final List<SnChatRoom> rooms;
}

class _GroupedChatSections {
  const _GroupedChatSections({
    required this.customGroups,
    required this.realmGroups,
    required this.ungroupedRooms,
  });

  final List<_CustomChatGroupSection> customGroups;
  final List<_RealmChatGroupSection> realmGroups;
  final List<SnChatRoom> ungroupedRooms;
}

List<SnChatMember> _getValidMembers(SnChatRoom room, SnAccount? userInfo) {
  var validMembers = room.members ?? <SnChatMember>[];
  if (validMembers.isNotEmpty && userInfo != null) {
    validMembers = validMembers
        .where((e) => e.accountId != userInfo.id)
        .toList();
  }
  return validMembers;
}

/// Online friends by account id, so a direct room can paint the same presence
/// sprite the explore feed paints for that friend.
Map<String, SnFriendOverviewItem> _getOnlineFriends(
  AsyncValue<List<SnFriendOverviewItem>> friendsOverview,
) {
  if (!friendsOverview.hasValue) {
    return const <String, SnFriendOverviewItem>{};
  }
  return {
    for (final friend in friendsOverview.value!)
      if (showsOnlinePresence(friend.status)) friend.account.id: friend,
  };
}

String _getRoomTitle(
  SnChatRoom room,
  List<SnChatMember> validMembers, {
  bool useAlias = false,
  Map<String, String>? aliases,
}) {
  if (room.type == 1 && room.name == null) {
    if (validMembers.isNotEmpty) {
      final memberNames = <String>[];
      for (final member in validMembers) {
        final alias = aliases?[member.accountId];
        memberNames.add(
          (alias != null && alias.isNotEmpty) ? alias : member.account.nick,
        );
      }
      return memberNames.join(', ');
    }
    return 'DM';
  }
  return room.name ?? '';
}

void _navigateToChatRoom(BuildContext context, String roomId) {
  if (isWideScreen(context)) {
    context.router.navigate(ChatRoomRoute(id: roomId));
  } else {
    context.router.push(ChatRoomRoute(id: roomId));
  }
}

Widget _buildChatRoomContextMenu({
  required BuildContext context,
  required WidgetRef ref,
  required SnChatRoom room,
  required AppDatabase db,
  required Dio client,
  required String? accountId,
  required List<SnChatGroup> chatGroups,
  required Future<void> Function() onChatGroupsChanged,
  required Widget child,
}) {
  return ContextMenuWidget(
    previewBuilder: contextMenuPreviewBuilder,
    menuProvider: (_) {
      return Menu(
        children: [
          MenuAction(
            title: room.isPinned ? tr('unpinRoom') : tr('pinRoom'),
            image: MenuImage.icon(
              room.isPinned ? Symbols.keep_off : Symbols.keep,
            ),
            callback: () async {
              await db.toggleChatRoomPinned(room.id);
              ref.invalidate(chatRoomJoinedProvider);
              await onChatGroupsChanged();
            },
          ),
          if (accountId != null)
            MenuAction(
              title: 'moveToGroup'.tr(),
              image: MenuImage.icon(Symbols.folder_open),
              callback: () async {
                final changedGroup = await showAssignChatGroupSheet(
                  context,
                  client: client,
                  db: db,
                  accountId: accountId,
                  room: room,
                  groups: chatGroups,
                );
                if (changedGroup) {
                  ref.invalidate(chatRoomJoinedProvider);
                  await onChatGroupsChanged();
                }
              },
            ),
          MenuAction(
            title: 'clearChatLocalData'.tr(),
            image: MenuImage.icon(Symbols.delete_forever),
            callback: () async {
              final confirmed = await showConfirmAlert(
                'clearChatLocalDataHint'.tr(),
                'clearChatLocalData'.tr(),
                icon: Symbols.delete_forever,
                isDanger: true,
              );
              if (!confirmed) return;

              try {
                await db.deleteChatRoomLocalData(room.id);
                ref.read(chatOutboxProvider.notifier).discardRoom(room.id);
                ref.invalidate(chatRoomJoinedProvider);
                ref.invalidate(chatRoomProvider(room.id));
                ref.invalidate(chatSummaryProvider);
                ref.invalidate(messagesProvider(room.id));

                if (ref.read(currentSubscribedChatIdProvider) == room.id) {
                  ref.read(currentSubscribedChatIdProvider.notifier).set(null);
                  ref
                      .read(foregroundChatRoomIdsProvider.notifier)
                      .remove(room.id);
                }

                await onChatGroupsChanged();
              } catch (err) {
                showErrorAlert(err);
              }
            },
          ),
        ],
      );
    },
    child: child,
  );
}

class _PinnedChatRoomTile extends HookConsumerWidget {
  final SnChatRoom room;
  final bool isActive;
  final bool isDirect;
  final VoidCallback onTap;
  final List<SnChatGroup> chatGroups;
  final Future<void> Function() onChatGroupsChanged;
  final String? accountId;

  const _PinnedChatRoomTile({
    required this.room,
    required this.isActive,
    required this.isDirect,
    required this.onTap,
    required this.chatGroups,
    required this.onChatGroupsChanged,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = ref
        .watch(chatSummaryProvider)
        .whenData((summaries) => summaries[room.id]);
    final unreadCount = summary.value?.unreadCount ?? 0;
    final hasUnread = summary.value?.hasUnread ?? unreadCount > 0;

    final userInfo = ref.watch(userInfoProvider);
    final validMembers = _getValidMembers(room, userInfo.value);

    final friendsOverview = ref.watch(friendsOverviewProvider);
    final onlineFriends = useMemoized(
      () => _getOnlineFriends(friendsOverview),
      [friendsOverview.value],
    );
    // The friend whose avatar the badge sits on: the DM's peer while they are
    // online. The badge itself picks dot vs activity colour and glyph, so the
    // pinned tile and the explore strip always agree.
    final presenceFriend = isDirect
        ? validMembers
              .map((member) => onlineFriends[member.accountId])
              .nonNulls
              .firstOrNull
        : null;

    // Build aliases map for title computation
    final aliases = useMemoized(() {
      final map = <String, String>{};
      for (final member in validMembers) {
        final aliasAsync = ref.read(
          relationshipAliasProvider(member.accountId),
        );
        if (aliasAsync.hasValue && aliasAsync.value != null) {
          map[member.accountId] = aliasAsync.value!;
        }
      }
      return map;
    }, [validMembers]);
    final titleText = _getRoomTitle(
      room,
      validMembers,
      useAlias: true,
      aliases: aliases,
    );

    final db = ref.watch(databaseProvider);
    final client = ref.watch(apiClientProvider);

    return _buildChatRoomContextMenu(
      context: context,
      ref: ref,
      room: room,
      db: db,
      client: client,
      accountId: accountId,
      chatGroups: chatGroups,
      onChatGroupsChanged: onChatGroupsChanged,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      if (isActive)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ChatRoomAvatar(
                        room: room,
                        isDirect: isDirect,
                        summary: summary,
                        validMembers: validMembers,
                        radius: isActive ? 20 : 22,
                      ),
                      if (presenceFriend != null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: FriendPresenceBadge(friend: presenceFriend),
                        ),
                    ],
                  ),
                ),
                const Gap(4),
                // Same label ramp as the explore strip: emphasis (bold, 0.95)
                // when the peer is online or the room has unread mail, else
                // the quieter 0.7. The active room keeps its primary tint as
                // the list's selection cue.
                Text(
                  titleText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight:
                        hasUnread || presenceFriend != null || isActive
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(
                            hasUnread || presenceFriend != null ? 0.95 : 0.7,
                          ),
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
int _totalUnreadForRooms(
  Iterable<SnChatRoom> rooms,
  Map<String, SnChatSummary> summaries,
) {
  return rooms.fold<int>(
    0,
    (sum, room) => sum + (summaries[room.id]?.unreadCount ?? 0),
  );
}

List<SnChatGroup> _normalizeChatGroups(List<SnChatGroup> groups) {
  final sorted = groups.toList()..sort((a, b) => a.order.compareTo(b.order));
  return [for (var i = 0; i < sorted.length; i++) sorted[i].copyWith(order: i)];
}

_GroupedChatSections _buildGroupedChatSections(
  List<SnChatRoom> rooms,
  List<SnChatGroup> chatGroups,
  Map<String, SnChatSummary> summaries,
) {
  final sortedGroups = _normalizeChatGroups(chatGroups);
  final roomById = {for (final room in rooms) room.id: room};
  final assignedRoomIds = <String>{};
  final customGroups = <_CustomChatGroupSection>[];

  for (final group in sortedGroups) {
    final groupRooms = <SnChatRoom>[];
    for (final roomId in group.roomIds) {
      final room = roomById[roomId];
      if (room == null || !assignedRoomIds.add(roomId)) continue;
      groupRooms.add(room);
    }
    customGroups.add(
      _CustomChatGroupSection(
        group: group,
        rooms: sortChatRoomsByActivity(groupRooms, summaries),
      ),
    );
  }

  final realmMap = <String, List<SnChatRoom>>{};
  final realmLookup = <String, SnRealm?>{};
  final ungrouped = <SnChatRoom>[];

  for (final room in rooms) {
    if (assignedRoomIds.contains(room.id)) continue;
    if (room.realmId != null) {
      realmMap.putIfAbsent(room.realmId!, () => []).add(room);
      realmLookup[room.realmId!] = room.realm;
    } else {
      ungrouped.add(room);
    }
  }

  return _GroupedChatSections(
    customGroups: customGroups,
    realmGroups: realmMap.entries
        .map(
          (entry) => _RealmChatGroupSection(
            realm: realmLookup[entry.key],
            rooms: entry.value,
          ),
        )
        .toList(),
    ungroupedRooms: ungrouped,
  );
}

class _ChatListSkeleton extends StatelessWidget {
  final double headerGap;

  const _ChatListSkeleton({this.headerGap = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (headerGap > 0)
            SliverToBoxAdapter(child: SizedBox(height: headerGap)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                itemCount: 6,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(radius: 20),
                      const SizedBox(height: 4),
                      Text(
                        'Friend',
                        style:
                            theme.textTheme.labelSmall?.copyWith(height: 1.1),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SolSpace.xl,
                    vertical: SolSpace.md,
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Room title placeholder',
                                    maxLines: 1,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '12:00 PM',
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Latest chat message preview that fits in the tile line',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: 8,
            ),
          ),
          const SliverGap(96),
        ],
      ),
    );
  }
}

class ChatListBodyWidget extends HookConsumerWidget {
  final bool isFloating;
  final TabController tabController;
  final ValueNotifier<int> selectedTab;
  final List<SnChatGroup> chatGroups;
  final Future<void> Function() onChatGroupsChanged;
  final String? accountId;

  /// Blank space held above the first room, in logical pixels.
  ///
  /// The pill floats over the list instead of occupying a row of its own, and a
  /// [CustomScrollView] ignores MediaQuery padding — only the box scroll views
  /// consume it — so the bar's band has to be reserved as a leading sliver. The
  /// caller passes `statusTop + kPillAppBarHeight`, or just the bar's height
  /// where the page has no status-bar inset to add.
  final double headerGap;

  /// Forwarded to a [NotificationListener] around the list so the enclosing
  /// view can drive the pill's fade off this list's own scroll.
  final bool Function(ScrollNotification notification)? onScroll;

  const ChatListBodyWidget({
    super.key,
    this.isFloating = false,
    this.headerGap = 0,
    this.onScroll,
    required this.tabController,
    required this.selectedTab,
    required this.chatGroups,
    required this.onChatGroupsChanged,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatRoomJoinedProvider);
    final settings = ref.watch(appSettingsProvider);
    final summaries = ref.watch(chatSummaryProvider);
    ref.watch(
      chatGlobalSyncProvider,
    ); // Ensure global sync WebSocket listener is active
    final activeChatId = ref.watch(currentSubscribedChatIdProvider);
    final accountStatus = ref.watch(chatAccountStatusProvider);
    final selectedTabValue = selectedTab.value;
    final db = ref.watch(databaseProvider);
    final client = ref.watch(apiClientProvider);
    final friendsOverview = ref.watch(friendsOverviewProvider);

    Widget buildRoomTile(SnChatRoom room) {
      // Keep a room's element (and its image/animation state) attached to its
      // ID when activity sorting moves it within the list.
      return KeyedSubtree(
        key: ValueKey('chat-room-${room.id}'),
        child: _buildChatRoomContextMenu(
          context: context,
          ref: ref,
          room: room,
          db: db,
          client: client,
          accountId: accountId,
          chatGroups: chatGroups,
          onChatGroupsChanged: onChatGroupsChanged,
          child: ChatRoomListTile(
            room: room,
            isDirect: room.type == 1,
            selected: activeChatId == room.id,
            pushNotificationsSuppressed:
                accountStatus
                    .whenData((data) => data)
                    .value
                    ?.isPushNotificationsSuppressed(room.id) ??
                false,
            onTap: () => _navigateToChatRoom(context, room.id),
          ),
        ),
      );
    }

    Widget bodyWidget = Column(
      children: [
        Expanded(
          child: chats.when(
            data: (items) {
              if (items.isEmpty && ref.watch(chatSyncingProvider)) {
                return _ChatListSkeleton(headerGap: headerGap);
              }
              final summariesData =
                  summaries.whenData((data) => data).value ?? {};
              final sortedItems = useMemoized(
                () => sortChatRoomsByActivity(items, summariesData),
                [items, summariesData],
              );
              final filteredItems = useMemoized(
                () => sortedItems
                    .where(
                      (item) =>
                          selectedTabValue == 0 ||
                          (selectedTabValue == 1 && item.type == 1) ||
                          (selectedTabValue == 2 && item.type != 1),
                    )
                    .toList(),
                [sortedItems, selectedTabValue],
              );
              final onlineFriends = useMemoized(
                () => _getOnlineFriends(friendsOverview),
                [friendsOverview.value],
              );
              // Pinned strip is quick access only; rooms still appear in the main list.
              final pinnedItems = useMemoized(() {
                final seen = <String>{};
                final pinned = <SnChatRoom>[];
                for (final item in filteredItems) {
                  if (!seen.add(item.id)) continue;
                  if (item.isPinned) {
                    pinned.add(item);
                  } else if (item.type == 1 &&
                      item.members != null &&
                      item.members!.any(
                        (m) => onlineFriends.containsKey(m.accountId),
                      )) {
                    pinned.add(item);
                  }
                }
                return pinned;
              }, [filteredItems, onlineFriends]);
              final groupedSections = useMemoized(
                () => _buildGroupedChatSections(
                  filteredItems,
                  chatGroups,
                  summariesData,
                ),
                [filteredItems, chatGroups, summariesData],
              );

              return RefreshIndicator(
                onRefresh: () async {
                  // Invalidate the chat room provider to refresh the list
                  ref.invalidate(chatRoomJoinedProvider);

                  // Also trigger global chat sync to fetch all messages from all rooms
                  try {
                    await ref
                        .read(chatGlobalSyncProvider.notifier)
                        .syncAllMessages();
                    Logger.root.info(
                      'Pull-to-refresh: Global chat sync completed',
                    );
                  } catch (e) {
                    Logger.root.info(
                      'Pull-to-refresh: Global chat sync failed',
                    );
                  }
                },
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: CustomScrollView(
                    slivers: [
                      // The bar floats over this list, so its band has to be
                      // reserved here: a CustomScrollView ignores MediaQuery
                      // padding, so nothing else pushes the first room below the
                      // capsule.
                      if (headerGap > 0)
                        SliverToBoxAdapter(child: SizedBox(height: headerGap)),
                      // Global notification status indicator
                      if (accountStatus
                              .whenData((data) => data)
                              .value
                              ?.pushNotificationsMaySendForUnsubscribedRooms ==
                          false)
                        SliverToBoxAdapter(
                          child: Material(
                            color: Theme.of(
                              context,
                            ).colorScheme.errorContainer.withOpacity(0.35),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                10,
                                14,
                                10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Symbols.notifications_off,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Limited Notifications',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Push notifications are disabled for unsubscribed rooms',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                                height: 1.25,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      // Quick access, styled like the explore feed's friend
                      // strip but without its floating card: the chat list is
                      // already one continuous surface, so the avatars sit
                      // straight on it, inset by the feed's 12px gutter and
                      // separated from the room list by one card gap instead
                      // of a rule. Pinned rooms and DMs with an online peer
                      // both land here; rooms still appear in the list below.
                      if (pinnedItems.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          // Height: 10 top + 48 avatar + 4 gap + ~14 label
                          // + 8 bottom, exactly the explore strip.
                          child: SizedBox(
                            height: 84,
                            child: HoverHorizontalScrollList(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                10,
                                12,
                                8,
                              ),
                              itemCount: pinnedItems.length,
                              separatorWidth: 2,
                              itemBuilder: (context, index) {
                                final room = pinnedItems[index];
                                return Align(
                                  alignment: Alignment.topCenter,
                                  child: _PinnedChatRoomTile(
                                    room: room,
                                    isActive: activeChatId == room.id,
                                    isDirect: room.type == 1,
                                    onTap: () {
                                      ref
                                          .read(chatSummaryProvider.future)
                                          .then((summary) {
                                            if (summary[room.id]?.hasUnread ??
                                                false) {
                                              ref
                                                  .read(
                                                    chatSummaryProvider
                                                        .notifier,
                                                  )
                                                  .clearUnreadCount(room.id);
                                            }
                                          });
                                      if (isWideScreen(context)) {
                                        context.router.navigate(
                                          ChatRoomRoute(id: room.id),
                                        );
                                      } else {
                                        context.router.push(
                                          ChatRoomRoute(id: room.id),
                                        );
                                      }
                                    },
                                    chatGroups: chatGroups,
                                    onChatGroupsChanged: onChatGroupsChanged,
                                    accountId: accountId,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final colorScheme = theme.colorScheme;

                          Widget buildSectionHeader({
                            required Widget leading,
                            required String title,
                            required int totalUnread,
                          }) {
                            return Row(
                              children: [
                                leading,
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                                if (totalUnread > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      totalUnread > 99
                                          ? '99+'
                                          : totalUnread.toString(),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.w700,
                                            height: 1.1,
                                          ),
                                    ),
                                  ),
                              ],
                            );
                          }

                          if (settings.groupedChatList &&
                              selectedTabValue == 0) {
                            final children = <Widget>[];

                            for (final section
                                in groupedSections.customGroups) {
                              final rooms = section.rooms;
                              final totalUnread = _totalUnreadForRooms(
                                rooms,
                                summariesData,
                              );
                              final groupColor =
                                  chatGroupColorFromHex(section.group.color) ??
                                  colorScheme.primary;

                              children.add(
                                Theme(
                                  data: theme.copyWith(
                                    dividerColor: Colors.transparent,
                                  ),
                                  child: ExpansionTile(
                                    backgroundColor: colorScheme
                                        .surfaceContainerHighest
                                        .withOpacity(0.28),
                                    collapsedBackgroundColor:
                                        Colors.transparent,
                                    collapsedShape:
                                        const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(SolRadius.control),
                                          ),
                                        ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(SolRadius.control),
                                      ),
                                    ),
                                    tilePadding: const EdgeInsets.fromLTRB(
                                      28,
                                      2,
                                      20,
                                      2,
                                    ),
                                    childrenPadding: EdgeInsets.zero,
                                    title: buildSectionHeader(
                                      leading: CircleAvatar(
                                        radius: 15,
                                        backgroundColor: groupColor.withOpacity(
                                          0.14,
                                        ),
                                        foregroundColor: groupColor,
                                        child: buildChatGroupIconWidget(
                                          section.group.icon,
                                          color: groupColor,
                                        ),
                                      ),
                                      title: section.group.name,
                                      totalUnread: totalUnread,
                                    ),
                                    children: [
                                      for (final room in rooms)
                                        buildRoomTile(room),
                                      if (rooms.isEmpty)
                                        const EmptyState(
                                          icon: Symbols.inbox,
                                          title: 'No rooms assigned yet',
                                          compact: true,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            for (final section in groupedSections.realmGroups) {
                              final realm = section.realm;
                              final rooms = section.rooms;
                              final realmName = realm?.name ?? 'Unknown Realm';
                              final totalUnread = _totalUnreadForRooms(
                                rooms,
                                summariesData,
                              );

                              children.add(
                                Theme(
                                  data: theme.copyWith(
                                    dividerColor: Colors.transparent,
                                  ),
                                  child: ExpansionTile(
                                    backgroundColor: colorScheme
                                        .surfaceContainerHighest
                                        .withOpacity(0.28),
                                    collapsedBackgroundColor:
                                        Colors.transparent,
                                    collapsedShape: RoundedRectangleBorder(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(SolRadius.control),
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(SolRadius.control),
                                      ),
                                    ),
                                    tilePadding: const EdgeInsets.fromLTRB(
                                      28,
                                      2,
                                      20,
                                      2,
                                    ),
                                    childrenPadding: EdgeInsets.zero,
                                    title: buildSectionHeader(
                                      leading: ProfilePictureWidget(
                                        file: realm?.picture,
                                        fallbackName: realm?.name,
                                        radius: 15,
                                      ),
                                      title: realmName,
                                      totalUnread: totalUnread,
                                    ),
                                    children: [
                                      for (final room in rooms)
                                        buildRoomTile(room),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (groupedSections.ungroupedRooms.isNotEmpty) {
                              children.addAll(
                                groupedSections.ungroupedRooms.map(
                                  buildRoomTile,
                                ),
                              );
                            }

                            if (children.isEmpty) {
                              return SliverFillRemaining(
                                hasScrollBody: false,
                                child: EmptyState(
                                  icon: Symbols.chat_bubble_outline,
                                  title: 'noChatRoomsAvailable'.tr(),
                                  compact: true,
                                ),
                              );
                            }

                            return SliverList(
                              delegate: SliverChildListDelegate(children),
                            );
                          } else {
                            if (filteredItems.isEmpty) {
                              return SliverFillRemaining(
                                hasScrollBody: false,
                                child: EmptyState(
                                  icon: Symbols.chat_bubble_outline,
                                  title: 'noChatRoomsAvailable'.tr(),
                                  compact: true,
                                ),
                              );
                            }

                            return SuperSliverList.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return buildRoomTile(item);
                              },
                            );
                          }
                        },
                      ),
                      const SliverGap(96),
                    ],
                  ),
                ),
              );
            },
            loading: () => _ChatListSkeleton(headerGap: headerGap),
            error: (error, stack) => ResponseErrorWidget(
              error: error,
              onRetry: () {
                ref.invalidate(chatRoomJoinedProvider);
              },
            ),
          ),
        ),
      ],
    );

    // The pill floats over this body, so the scroll has to reach its fade.
    // The reserved band is a leading sliver *inside* the viewport, not padding
    // around it: content clears the capsule when the list is at its origin and
    // then travels up underneath the glass as the user scrolls.
    return NotificationListener<ScrollNotification>(
      onNotification: onScroll ?? (_) => false,
      child: isFloating ? Card(child: bodyWidget) : bodyWidget,
    );
  }
}

@RoutePage()
class ChatListScreen extends HookWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (isWideScreen(context)) return const SizedBox.shrink();
    return const ChatListWidget();
  }
}

@RoutePage()
class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    final tabsRouter = AutoTabsRouter.of(context);

    useEffect(() {
      StackRouter? chatRouter;

      void clearActiveChat() {
        final activeChatId = ref.read(currentSubscribedChatIdProvider);
        if (activeChatId == null) return;
        ref.read(currentSubscribedChatIdProvider.notifier).set(null);
        ref.read(foregroundChatRoomIdsProvider.notifier).remove(activeChatId);
      }

      void syncActiveChatWithRoute() {
        final nextChatRouter = tabsRouter.stackRouterOfIndex(2);
        if (nextChatRouter != chatRouter) {
          chatRouter?.removeListener(syncActiveChatWithRoute);
          chatRouter = nextChatRouter;
          chatRouter?.addListener(syncActiveChatWithRoute);
        }

        // AutoTabsRouter keeps inactive tabs mounted, and the nested router
        // changes when users leave a room with the back button. In both cases,
        // only an actual ChatRoomRoute should have an active list highlight.
        if (tabsRouter.activeIndex != 2) {
          clearActiveChat();
          return;
        }

        final route = chatRouter?.topRoute;
        if (route?.name != ChatRoomRoute.name) {
          clearActiveChat();
          return;
        }

        final roomId = route?.pathParams.getString('id');
        if (roomId == null || roomId.isEmpty) return;
        ref.read(currentSubscribedChatIdProvider.notifier).set(roomId);
        ref.read(foregroundChatRoomIdsProvider.notifier).add(roomId);
      }

      tabsRouter.addListener(syncActiveChatWithRoute);
      syncActiveChatWithRoute();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) syncActiveChatWithRoute();
      });
      return () {
        tabsRouter.removeListener(syncActiveChatWithRoute);
        chatRouter?.removeListener(syncActiveChatWithRoute);
      };
    }, [tabsRouter]);

    return AppBackground(
      isRoot: true,
      child: isWide
          ? SafeArea(
              child: Row(
                children: [
                  // One gutter (SolSpace.sm) on every edge of the split, so the
                  // list pane reads as centred between the rail and the room
                  // card instead of hugging the left at 8 while floating 20 off
                  // the card. Matches the chat input's wide-screen margins.
                  const ChatListWidget(
                    isAside: true,
                  ).padding(left: SolSpace.sm),
                  const Gap(SolSpace.sm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(SolRadius.card),
                        topRight: Radius.circular(SolRadius.card),
                      ),
                      child: AutoRouter(
                        builder: (context, child) {
                          return Card(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLowest,
                            margin: .zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(SolRadius.card),
                                topRight: Radius.circular(SolRadius.card),
                              ),
                            ),
                            child: child,
                          );
                        },
                      ),
                    ).padding(top: 16, right: SolSpace.sm),
                  ),
                ],
              ),
            )
          : const AutoRouter(),
    );
  }

  /// The chat tab's create sheet: new room, direct message, invites.
  static void _showCreateSheet(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SnChatMember>> chatInvites,
  ) {
    Future<void> openInvites() async {
      await showModalBottomSheet(
        useRootNavigator: true,
        isScrollControlled: true,
        context: context,
        builder: (context) => const ChatInvitesSheet(),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(40),
          ListTile(
            title: Text('createChatRoom'.tr()),
            leading: const Icon(Symbols.add),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            onTap: () {
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                builder: (context) => const EditChatScreen(),
              ).then((value) {
                if (value != null) {
                  eventBus.fire(const ChatRoomsRefreshEvent());
                }
              });
            },
          ),
          ListTile(
            title: Text('createDirectMessage'.tr()),
            leading: const Icon(Symbols.person),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            onTap: () async {
              final result = await showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                builder: (context) => const AccountPickerSheet(),
              );
              if (result == null) return;
              if (!context.mounted) return;

              final client = ref.read(apiClientProvider);
              try {
                await client.post(
                  '/messager/chat/direct',
                  data: {'related_user_id': result.id},
                );
                eventBus.fire(const ChatRoomsRefreshEvent());
              } catch (err) {
                showErrorAlert(err);
              }
            },
          ),
          ListTile(
            title: Text('invites'.tr()),
            leading: const Icon(Symbols.mail),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            trailing: Badge(
              label: Text(
                chatInvites.when(
                  data: (invites) => invites.length.toString(),
                  error: (_, _) => '0',
                  loading: () => '0',
                ),
              ),
              isLabelVisible: chatInvites.when(
                data: (invites) => invites.isNotEmpty,
                error: (_, _) => false,
                loading: () => false,
              ),
            ),
            onTap: openInvites,
          ),
          const Gap(16),
        ],
      ),
    );
  }
}

/// The chat tab's create button: new room, direct message, invites.
///
/// Owned by the tab itself rather than by the shell, so the button sits in the
/// list pane on the wide layout and floats over the page on narrow ones.
class ChatFabWidget extends HookConsumerWidget {
  const ChatFabWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    if (userInfo.value == null) return const SizedBox.shrink();

    final chatInvites = ref.watch(chatroomInvitesProvider);
    return FloatingActionButton(
      heroTag: 'chat-fab',
      tooltip: 'createChatRoom'.tr(),
      child: const Icon(Symbols.add),
      onPressed: () => ChatScreen._showCreateSheet(context, ref, chatInvites),
    );
  }
}

/// The three chat filters (all / direct / groups) as one dropdown, in the same
/// shape as the explore page's section picker: the current filter's icon and
/// label as the trigger, the alternatives in the menu.
///
/// It drives the page's [TabController] instead of replacing it, so the list
/// below stays a tab view and the switcher leads the header instead of
/// carrying a separate title next to it.
class _ChatSectionButton extends StatelessWidget {
  final TabController tabController;

  const _ChatSectionButton({required this.tabController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // The controller is the source of truth, and a swipe on the tab view moves
    // it without rebuilding this widget, so listen rather than read once.
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        final selected = _chatSections[tabController.index];
        return MenuAnchor(
          animated: true,
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(
              colorScheme.surfaceContainerHigh,
            ),
            shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: SolRadius.menuRadius),
            ),
          ),
          builder: (context, controller, child) {
            return InkWell(
              borderRadius: SolRadius.pillRadius,
              onTap: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SolSpace.sm,
                  vertical: SolSpace.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: SolSpace.sm,
                  children: [
                    Icon(selected.icon, size: 20, color: colorScheme.onSurface),
                    Flexible(
                      child: Text(
                        selected.label.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.appBarTheme.titleTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          menuChildren: [
            for (final (index, section) in _chatSections.indexed)
              MenuItemButton(
                leadingIcon: Icon(section.icon, size: 20),
                trailingIcon: tabController.index == index
                    ? const Icon(Symbols.check, size: 18)
                    : null,
                onPressed: () => tabController.animateTo(index),
                child: Text(section.label.tr()),
              ),
          ],
        );
      },
    );
  }
}

class _ChatSection {
  final String label;
  final IconData icon;

  const _ChatSection({required this.label, required this.icon});
}

/// Ordered to match the page's three tabs.
const _chatSections = <_ChatSection>[
  _ChatSection(label: 'chatTabAll', icon: Symbols.inbox),
  _ChatSection(label: 'chatTabDirect', icon: Symbols.person),
  _ChatSection(label: 'chatTabGroup', icon: Symbols.group),
];

class _MarkAllReadButton extends ConsumerWidget {
  final Color? color;

  const _MarkAllReadButton({this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readSyncState = ref.watch(chatReadSyncProvider);
    final unreadCount = ref.watch(chatUnreadCountProvider).value ?? 0;

    if (unreadCount <= 0) {
      return const SizedBox.shrink();
    }

    return IconButton(
      color: color,
      icon: readSyncState.isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(Symbols.done_all),
      tooltip: 'Mark all as read',
      onPressed: readSyncState.isLoading
          ? null
          : () async {
              try {
                await ref.read(chatReadSyncProvider.notifier).markAllRead();
              } catch (err) {
                showErrorAlert(err);
              }
            },
    );
  }
}

/// The section picker and its trailing actions. The header wraps them in its
/// own glass capsule ([PillSplitBar]), so this row paints no surface.

class _ChatHeaderActions extends StatelessWidget {
  final TabController tabController;
  final Color foreground;

  const _ChatHeaderActions({
    required this.tabController,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: _ChatSectionButton(tabController: tabController)),
        _MarkAllReadButton(color: foreground),
      ],
    );
  }
}

/// Portrait chat header: the shared split pair of glass surfaces.
///
/// The navigation toggle and the section picker sit together at the top-left,
/// mirroring the wide pane; the picker's trailing actions stay inside its pill.
class _ChatSplitBar extends StatelessWidget implements PreferredSizeWidget {
  final double statusTop;
  final TabController tabController;
  final bool isSyncing;
  final Color foreground;

  const _ChatSplitBar({
    required this.statusTop,
    required this.tabController,
    required this.isSyncing,
    required this.foreground,
  });

  @override
  Size get preferredSize => Size.fromHeight(statusTop + kPillSplitBarBand);

  @override
  Widget build(BuildContext context) {
    return PillSplitBar(
      statusTop: statusTop,
      loading: isSyncing,
      child: _ChatHeaderActions(
        tabController: tabController,
        foreground: foreground,
      ),
    );
  }
}

/// Floating controls above the wide chat layout's list pane.
///
/// The navigation toggle (where the rail cannot show one) and the section
/// picker lead the pane's top row, both at the same band as the list's gap.
class _ChatListFloatingButtons extends StatelessWidget {
  final TabController tabController;
  final bool isSyncing;
  final Color foreground;

  const _ChatListFloatingButtons({
    required this.tabController,
    required this.isSyncing,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return PillSplitBar(
      statusTop: 0,
      loading: isSyncing,
      child: _ChatHeaderActions(
        tabController: tabController,
        foreground: foreground,
      ),
    );
  }
}

class ChatListWidget extends HookConsumerWidget {
  final bool isAside;
  const ChatListWidget({super.key, this.isAside = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useMaterialTabController(initialLength: 3);
    final selectedTab = useState(
      0,
    ); // 0 for All, 1 for Direct Messages, 2 for Group Chats
    final isSyncing = ref.watch(chatSyncingProvider) ||
        ref.watch(chatSummaryProvider).isLoading;
    final lifecycleState = ref.watch(appLifecycleStateProvider);
    final previousLifecycleState = useRef<AppLifecycleState?>(null);
    final isResyncingAfterResume = useState(false);
    final userInfo = ref.watch(userInfoProvider);
    final accountId = userInfo.value?.id;
    final chatGroups =
        ref.watch(chatGroupsProvider).value ?? const <SnChatGroup>[];
    // Drives the pill's glass the same way the explore and search pages do: a
    // notifier rather than setState, so a scroll tick repaints the bar only.
    final fade = useValueNotifier(0.0);

    Future<void> refreshChatGroups() async {
      ref.invalidate(chatGroupsProvider);
    }

    useEffect(() {
      tabController.addListener(() {
        selectedTab.value = tabController.index;
      });

      // Listen for chat rooms refresh events
      final roomSubscription = eventBus.on<ChatRoomsRefreshEvent>().listen((
        event,
      ) {
        ref.invalidate(chatRoomJoinedProvider);
      });
      final groupSubscription = eventBus.on<ChatGroupsRefreshEvent>().listen((
        event,
      ) {
        ref.invalidate(chatGroupsProvider);
      });

      return () {
        roomSubscription.cancel();
        groupSubscription.cancel();
      };
    }, [tabController]);

    useEffect(() {
      final nextState = lifecycleState.value;
      if (nextState == null) return null;

      final previousState = previousLifecycleState.value;
      final resumedFromUnfocused =
          nextState == AppLifecycleState.resumed &&
          previousState != null &&
          previousState != AppLifecycleState.resumed;

      if (resumedFromUnfocused && !isResyncingAfterResume.value) {
        isResyncingAfterResume.value = true;
        Future<void>(() async {
          try {
            Logger.root.info(
              'Chat list resumed from $previousState, triggering eager global sync',
            );
            await ref.read(chatGlobalSyncProvider.notifier).syncAllMessages();
            ref.invalidate(chatRoomJoinedProvider);
          } catch (e, stackTrace) {
            Logger.root.info(
              'Chat list eager resume sync failed',
              e,
              stackTrace,
            );
          } finally {
            if (context.mounted) {
              isResyncingAfterResume.value = false;
            }
          }
        });
      }

      previousLifecycleState.value = nextState;
      return null;
    }, [lifecycleState.value]);

    final asideLayout = isAside || isWideScreen(context);
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final sidebarWidth = useState(320.0);
    const minSidebarWidth = 260.0;
    const maxSidebarWidth = 520.0;

    if (asideLayout) {
      // No outer card: the pane floats on the page background, and only the
      // floating pills carry a surface.
      return SizedBox(
        width: sidebarWidth.value,
        child: Stack(
          children: [
            // The room list runs the full height of the pane; the band above
            // it is reserved so the floating controls never cover a room.
            ChatListBodyWidget(
              isFloating: false,
              tabController: tabController,
              selectedTab: selectedTab,
              chatGroups: chatGroups,
              onChatGroupsChanged: refreshChatGroups,
              accountId: accountId,
              headerGap: kPillSplitBarBand,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _ChatListFloatingButtons(
                tabController: tabController,
                isSyncing: isSyncing,
                foreground: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 6,
              child: ChatFabWidget().padding(bottom: 16, right: 8),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) {
                    final next = (sidebarWidth.value + details.delta.dx).clamp(
                      minSidebarWidth,
                      maxSidebarWidth,
                    );
                    sidebarWidth.value = next;
                  },
                  child: const SizedBox(width: 10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    // Same as the explore header: a tonal surface band, never the saturated
    // primary color. The foreground has to be threaded into every child
    // because the title and actions are not covered by the AppBar's own
    // foreground `IconTheme`.
    final appBarForeground = colorScheme.onSurface;
    // Same band the explore and search pages reserve for their pills, so the
    // first room tile clears the capsule instead of starting under it.
    final statusTop = MediaQuery.paddingOf(context).top;

    return AppScaffold(
      extendBody: false,
      // The list scrolls under the pill and drives its glass, instead of being
      // pushed below a solid band.
      appBarOverContent: true,
      floatingActionButton: const ChatFabWidget().padding(
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      appBar: isPortrait
          ? _ChatSplitBar(
              statusTop: statusTop,
              tabController: tabController,
              isSyncing: isSyncing,
              foreground: appBarForeground,
            )
          : PillAppBar(
              fade: fade,
              statusTop: statusTop,
              loading: isSyncing,
              child: Row(
                children: [
                  const SolDrawerButton(),
                  const Gap(SolSpace.sm),
                  // Same placement as the explore bar: the picker takes the
                  // title slot and the actions stay flush right.
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _ChatSectionButton(tabController: tabController),
                    ),
                  ),
                  _MarkAllReadButton(color: appBarForeground),
                ],
              ),
            ),
      body: userInfo.value == null
          ? const ResponseUnauthorizedWidget()
          : Column(
              children: [
                Expanded(
                  child: ChatListBodyWidget(
                    isFloating: false,
                    tabController: tabController,
                    selectedTab: selectedTab,
                    chatGroups: chatGroups,
                    onChatGroupsChanged: refreshChatGroups,
                    accountId: accountId,
                    headerGap: isPortrait
                        ? statusTop + kPillSplitBarBand
                        : statusTop + kPillAppBarHeight,
                    onScroll: isPortrait
                        ? null
                        : (notification) => updatePillFade(notification, fade),
                  ),
                ),
              ],
            ),
    );
  }
}
