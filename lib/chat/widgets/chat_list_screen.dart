import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/relationship_pod.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/chat/pods/chat_account_status.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:island/chat/pods/chat_summary.dart';
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
import 'package:island/core/services/responsive.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/data/database.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

DateTime _chatRoomActivityAt(
  SnChatRoom room,
  Map<String, SnChatSummary> summaries,
) {
  return summaries[room.id]?.lastMessage?.createdAt ?? room.updatedAt;
}

List<SnChatRoom> _sortChatRoomsByActivity(
  Iterable<SnChatRoom> rooms,
  Map<String, SnChatSummary> summaries,
) {
  return rooms.toList()..sort((a, b) {
    final activityComparison = _chatRoomActivityAt(
      b,
      summaries,
    ).compareTo(_chatRoomActivityAt(a, summaries));
    if (activityComparison != 0) return activityComparison;

    final createdComparison = b.createdAt.compareTo(a.createdAt);
    if (createdComparison != 0) return createdComparison;

    return a.id.compareTo(b.id);
  });
}

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

Set<String> _getOnlineFriendIds(
  AsyncValue<List<SnFriendOverviewItem>> friendsOverview,
) {
  if (!friendsOverview.hasValue) return <String>{};
  return friendsOverview.value!
      .where((f) => showsOnlinePresence(f.status))
      .map((f) => f.account.id)
      .toSet();
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
            title: room.isPinned ? 'Unpin Room' : 'Pin Room',
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
              title: 'Move To Group',
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
    final summary = ref
        .watch(chatSummaryProvider)
        .whenData((summaries) => summaries[room.id]);

    final userInfo = ref.watch(userInfoProvider);
    final validMembers = _getValidMembers(room, userInfo.value);

    final friendsOverview = ref.watch(friendsOverviewProvider);
    final onlineFriendIds = useMemoized(
      () => _getOnlineFriendIds(friendsOverview),
      [friendsOverview.value],
    );
    final isOnline =
        isDirect &&
        validMembers.any((m) => onlineFriendIds.contains(m.accountId));

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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isActive)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ChatRoomAvatar(
                      room: room,
                      isDirect: isDirect,
                      summary: summary,
                      validMembers: validMembers,
                      radius: 22,
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Gap(4),
              Text(
                titleText,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).center();
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
        rooms: _sortChatRoomsByActivity(groupRooms, summaries),
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

class ChatListBodyWidget extends HookConsumerWidget {
  final bool isFloating;
  final TabController tabController;
  final ValueNotifier<int> selectedTab;
  final List<SnChatGroup> chatGroups;
  final Future<void> Function() onChatGroupsChanged;
  final String? accountId;

  const ChatListBodyWidget({
    super.key,
    this.isFloating = false,
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
      return _buildChatRoomContextMenu(
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
      );
    }

    Widget bodyWidget = Column(
      children: [
        Expanded(
          child: chats.when(
            data: (items) {
              final summariesData =
                  summaries.whenData((data) => data).value ?? {};
              final sortedItems = useMemoized(
                () => _sortChatRoomsByActivity(items, summariesData),
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
              final onlineFriendIds = useMemoized(
                () => _getOnlineFriendIds(friendsOverview),
                [friendsOverview.value],
              );
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
                        (m) => onlineFriendIds.contains(m.accountId),
                      )) {
                    pinned.add(item);
                  }
                }
                return pinned;
              }, [filteredItems, onlineFriendIds]);
              final pinnedIds = useMemoized(
                () => pinnedItems.map((e) => e.id).toSet(),
                [pinnedItems],
              );
              final unpinnedItems = useMemoized(
                () => filteredItems
                    .where((item) => !pinnedIds.contains(item.id))
                    .toList(),
                [filteredItems, pinnedIds],
              );
              final groupedSections = useMemoized(
                () => _buildGroupedChatSections(
                  unpinnedItems,
                  chatGroups,
                  summariesData,
                ),
                [unpinnedItems, chatGroups, summariesData],
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
                  child: Column(
                    children: [
                      // Global notification status indicator
                      if (accountStatus
                              .whenData((data) => data)
                              .value
                              ?.pushNotificationsMaySendForUnsubscribedRooms ==
                          false)
                        ListTile(
                          leading: Icon(
                            Symbols.notifications_off,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(
                            'Limited Notifications',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Push notifications are disabled for unsubscribed rooms',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          dense: true,
                          tileColor: Theme.of(
                            context,
                          ).colorScheme.errorContainer.withOpacity(0.3),
                        ),
                      // Always show pinned chats in horizontal scrollable section
                      if (pinnedItems.isNotEmpty)
                        Material(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh.withOpacity(0.8),
                          child: SizedBox(
                            height: 88,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: pinnedItems.length,
                              itemBuilder: (context, index) {
                                final room = pinnedItems[index];
                                return _PinnedChatRoomTile(
                                  room: room,
                                  isActive: activeChatId == room.id,
                                  isDirect: room.type == 1,
                                  onTap: () {
                                    ref.read(chatSummaryProvider.future).then((
                                      summary,
                                    ) {
                                      if ((summary[room.id]?.unreadCount ?? 0) >
                                          0) {
                                        ref
                                            .read(chatSummaryProvider.notifier)
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
                                );
                              },
                            ),
                          ),
                        ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
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
                                    chatGroupColorFromHex(
                                      section.group.color,
                                    ) ??
                                    Theme.of(context).colorScheme.primary;

                                children.add(
                                  ExpansionTile(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withOpacity(0.5),
                                    collapsedBackgroundColor:
                                        Colors.transparent,
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(section.group.name),
                                        ),
                                        Badge(
                                          isLabelVisible: totalUnread > 0,
                                          label: Text(totalUnread.toString()),
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          textColor: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                        ),
                                      ],
                                    ),
                                    leading: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: groupColor.withOpacity(
                                        0.16,
                                      ),
                                      foregroundColor: groupColor,
                                      child: buildChatGroupIconWidget(
                                        section.group.icon,
                                        color: groupColor,
                                      ),
                                    ),
                                    tilePadding: const EdgeInsets.only(
                                      left: 20,
                                      right: 24,
                                    ),
                                    children: [
                                      for (final room in rooms)
                                        buildRoomTile(room),
                                      if (rooms.isEmpty)
                                        const ListTile(
                                          dense: true,
                                          title: Text('No rooms assigned yet'),
                                        ),
                                    ],
                                  ),
                                );
                              }

                              for (final section
                                  in groupedSections.realmGroups) {
                                final realm = section.realm;
                                final rooms = section.rooms;
                                final realmName =
                                    realm?.name ?? 'Unknown Realm';
                                final totalUnread = _totalUnreadForRooms(
                                  rooms,
                                  summariesData,
                                );

                                children.add(
                                  ExpansionTile(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withOpacity(0.5),
                                    collapsedBackgroundColor:
                                        Colors.transparent,
                                    title: Row(
                                      children: [
                                        Expanded(child: Text(realmName)),
                                        Badge(
                                          isLabelVisible: totalUnread > 0,
                                          label: Text(totalUnread.toString()),
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          textColor: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                        ),
                                      ],
                                    ),
                                    leading: ProfilePictureWidget(
                                      file: realm?.picture,
                                      radius: 16,
                                    ),
                                    tilePadding: const EdgeInsets.only(
                                      left: 20,
                                      right: 24,
                                    ),
                                    children: [
                                      for (final room in rooms)
                                        buildRoomTile(room),
                                    ],
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

                              return ListView(
                                padding: EdgeInsets.only(bottom: 96),
                                children: children,
                              );
                            } else {
                              return SuperListView.builder(
                                padding: EdgeInsets.only(bottom: 96),
                                itemCount: unpinnedItems.length,
                                itemBuilder: (context, index) {
                                  final item = unpinnedItems[index];
                                  return buildRoomTile(item);
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => Center(
              child: ConfuseSpinner(
                size: 40,
                speed: 6,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.65),
              ),
            ),
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

    return isFloating ? Card(child: bodyWidget) : bodyWidget;
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

    return AppBackground(
      isRoot: true,
      child: isWide
          ? SafeArea(
              child: Row(
                children: [
                  const ChatListWidget(
                    isAside: true,
                  ).padding(left: 16, top: 16),
                  const Gap(8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: const AutoRouter(),
                    ).padding(top: 16, right: 16),
                  ),
                ],
              ),
            )
          : const AutoRouter(),
    );
  }
}

class ChatFabWidget extends HookConsumerWidget {
  const ChatFabWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);

    if (userInfo.value == null) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      heroTag: 'chat-fab',
      child: const Icon(Symbols.add),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(40),
              ListTile(
                title: const Text('createChatRoom').tr(),
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
                title: const Text('createDirectMessage').tr(),
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
              const Gap(16),
            ],
          ),
        );
      },
    );
  }
}

class _ChatListAppBar extends HookConsumerWidget {
  final TabController tabController;
  final List<SnChatGroup> chatGroups;
  final Future<void> Function() onChatGroupsChanged;
  final String? accountId;

  const _ChatListAppBar({
    required this.tabController,
    required this.chatGroups,
    required this.onChatGroupsChanged,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatInvites = ref.watch(chatroomInvitesProvider);
    final isSyncing = ref.watch(chatSyncingProvider);
    final appbarFeColor = Theme.of(context).appBarTheme.foregroundColor;

    Future<void> openInvites() async {
      await showModalBottomSheet(
        useRootNavigator: true,
        isScrollControlled: true,
        context: context,
        builder: (context) => const ChatInvitesSheet(),
      );
    }

    Widget buildInviteButton() {
      return IconButton(
        tooltip: 'Chat Invites',
        onPressed: openInvites,
        icon: Badge(
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
          child: Icon(Symbols.email, color: appbarFeColor),
        ),
      );
    }

    return Container(
      height: 48,
      margin: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 4 + MediaQuery.of(context).padding.top,
        bottom: 4,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Row(
                spacing: 8,
                children: [
                  IconButton(
                    icon: Icon(
                      Symbols.inbox,
                      fill: tabController.index == 0 ? 1 : 0,
                    ),
                    color: appbarFeColor,
                    onPressed: () => tabController.animateTo(0),
                    tooltip: 'chatTabAll'.tr(),
                  ),
                  IconButton(
                    icon: Icon(
                      Symbols.person,
                      fill: tabController.index == 1 ? 1 : 0,
                    ),
                    color: appbarFeColor,
                    onPressed: () => tabController.animateTo(1),
                    tooltip: 'chatTabDirect'.tr(),
                  ),
                  IconButton(
                    icon: Icon(
                      Symbols.group,
                      fill: tabController.index == 2 ? 1 : 0,
                    ),
                    color: appbarFeColor,
                    onPressed: () => tabController.animateTo(2),
                    tooltip: 'chatTabGroup'.tr(),
                  ),
                ],
              ),
            ),
            // Sync indicator
            if (isSyncing)
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: ConfuseSpinner(
                    size: 24,
                    speed: 7,
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.65),
                  ),
                ),
              ),
            const _MarkAllReadButton(),
            buildInviteButton(),
          ],
        ),
      ),
    );
  }
}

class _MarkAllReadButton extends ConsumerWidget {
  const _MarkAllReadButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readSyncState = ref.watch(chatReadSyncProvider);
    final unreadCount = ref.watch(chatUnreadCountProvider).value ?? 0;

    if (unreadCount <= 0) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: readSyncState.isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isWideScreen(context)
                    ? null
                    : Theme.of(context).appBarTheme.foregroundColor,
              ),
            )
          : Icon(
              Symbols.done_all,
              color: isWideScreen(context)
                  ? null
                  : Theme.of(context).appBarTheme.foregroundColor,
            ),
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

class _CollapsedChatListBody extends HookConsumerWidget {
  final ValueNotifier<int> selectedTab;
  final List<SnChatGroup> chatGroups;
  final Future<void> Function() onChatGroupsChanged;
  final String? accountId;

  const _CollapsedChatListBody({
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
    final userInfo = ref.watch(userInfoProvider);
    final activeChatId = ref.watch(currentSubscribedChatIdProvider);
    final db = ref.watch(databaseProvider);
    final client = ref.watch(apiClientProvider);

    String getRoomTitle(SnChatRoom room, List<SnChatMember> validMembers) {
      final lockPrefix = room.encryptionMode != 0 ? '🔒 ' : '';
      if (room.type == 1 && room.name == null) {
        if (validMembers.isNotEmpty) {
          return '$lockPrefix${validMembers.map((e) => e.account.nick).join(', ')}';
        }
        return '${lockPrefix}Direct Message';
      }
      return '$lockPrefix${room.name ?? 'Unnamed Chat'}';
    }

    Widget buildRoundAvatar(Widget child) {
      return ClipOval(
        child: SizedBox(
          width: 36,
          height: 36,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(width: 40, height: 40, child: child),
          ),
        ),
      );
    }

    Widget buildRoundedRectAvatar(Widget child) {
      return SizedBox(
        width: 36,
        height: 36,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(width: 40, height: 40, child: child),
        ),
      );
    }

    Widget withSelectedIndicator({
      required Widget child,
      required bool isSelected,
    }) {
      return SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.5,
                  ),
                ),
              ),
            child,
          ],
        ),
      );
    }

    return chats.when(
      data: (items) {
        final selectedTabValue = selectedTab.value;
        final summariesData = summaries.whenData((data) => data).value ?? {};
        final sortedItems = _sortChatRoomsByActivity(items, summariesData);
        final filteredItems = sortedItems
            .where(
              (item) =>
                  selectedTabValue == 0 ||
                  (selectedTabValue == 1 && item.type == 1) ||
                  (selectedTabValue == 2 && item.type != 1),
            )
            .toList();

        Widget buildRoomIconButton(SnChatRoom room) {
          final unread = summariesData[room.id]?.unreadCount ?? 0;
          final validMembers = _getValidMembers(room, userInfo.value);
          final title = getRoomTitle(room, validMembers);
          return withSelectedIndicator(
            isSelected: activeChatId == room.id,
            child: _buildChatRoomContextMenu(
              context: context,
              ref: ref,
              room: room,
              db: db,
              client: client,
              accountId: accountId,
              chatGroups: chatGroups,
              onChatGroupsChanged: onChatGroupsChanged,
              child: IconButton(
                tooltip: title,
                onPressed: () => _navigateToChatRoom(context, room.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 48,
                  height: 48,
                ),
                splashRadius: 24,
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text(unread.toString()),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  child: buildRoundAvatar(
                    ChatRoomAvatar(
                      room: room,
                      isDirect: room.type == 1,
                      summary: AsyncValue.data(summariesData[room.id]),
                      validMembers: validMembers,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final avatarTiles = <Widget>[];
        if (settings.groupedChatList && selectedTabValue == 0) {
          final groupedSections = _buildGroupedChatSections(
            filteredItems,
            chatGroups,
            summariesData,
          );

          for (final section in groupedSections.customGroups) {
            final rooms = section.rooms;
            final totalUnread = _totalUnreadForRooms(rooms, summariesData);
            final groupColor =
                chatGroupColorFromHex(section.group.color) ??
                Theme.of(context).colorScheme.primary;
            avatarTiles.add(
              withSelectedIndicator(
                isSelected: rooms.any((room) => room.id == activeChatId),
                child: PopupMenuButton<SnChatRoom>(
                  tooltip: section.group.name,
                  position: PopupMenuPosition.under,
                  onSelected: (room) => _navigateToChatRoom(context, room.id),
                  itemBuilder: (context) => [
                    PopupMenuItem<SnChatRoom>(
                      enabled: false,
                      child: Row(
                        spacing: 12,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: groupColor.withOpacity(0.16),
                            foregroundColor: groupColor,
                            child: buildChatGroupIconWidget(
                              section.group.icon,
                              color: groupColor,
                            ),
                          ),
                          Text(
                            section.group.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ).bold(),
                        ],
                      ).padding(horizontal: 8),
                    ),
                    ...rooms.map((room) {
                      final unread = summariesData[room.id]?.unreadCount ?? 0;
                      final validMembers = _getValidMembers(
                        room,
                        userInfo.value,
                      );
                      return PopupMenuItem<SnChatRoom>(
                        value: room,
                        child: Row(
                          spacing: 12,
                          children: [
                            ChatRoomAvatar(
                              room: room,
                              isDirect: room.type == 1,
                              summary: AsyncValue.data(summariesData[room.id]),
                              validMembers: validMembers,
                              hideRealm: true,
                              radius: 16,
                            ),
                            Expanded(
                              child: Text(
                                getRoomTitle(room, validMembers),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (unread > 0)
                              Badge(
                                label: Text(unread.toString()),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                textColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                              ),
                          ],
                        ).padding(horizontal: 8),
                      );
                    }),
                  ],
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Badge(
                        isLabelVisible: totalUnread > 0,
                        label: Text(totalUnread.toString()),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        textColor: Theme.of(context).colorScheme.onPrimary,
                        child: buildRoundedRectAvatar(
                          Container(
                            color: groupColor.withOpacity(0.16),
                            child: Center(
                              child: buildChatGroupIconWidget(
                                section.group.icon,
                                color: groupColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          for (final section in groupedSections.realmGroups) {
            final realm = section.realm;
            final rooms = section.rooms;
            final totalUnread = _totalUnreadForRooms(rooms, summariesData);
            avatarTiles.add(
              withSelectedIndicator(
                isSelected: rooms.any((room) => room.id == activeChatId),
                child: PopupMenuButton<SnChatRoom>(
                  tooltip: realm?.name ?? 'Group',
                  position: PopupMenuPosition.under,
                  onSelected: (room) => _navigateToChatRoom(context, room.id),
                  itemBuilder: (context) => [
                    PopupMenuItem<SnChatRoom>(
                      enabled: false,
                      child: Row(
                        spacing: 12,
                        children: [
                          ProfilePictureWidget(
                            file: realm?.picture,
                            radius: 16,
                          ),
                          Text(
                            realm?.name ?? 'Unknown Realm',
                            style: Theme.of(context).textTheme.titleSmall,
                          ).bold(),
                        ],
                      ).padding(horizontal: 8),
                    ),
                    ...rooms.map((room) {
                      final unread = summariesData[room.id]?.unreadCount ?? 0;
                      final validMembers = _getValidMembers(
                        room,
                        userInfo.value,
                      );
                      return PopupMenuItem<SnChatRoom>(
                        value: room,
                        child: Row(
                          spacing: 12,
                          children: [
                            ChatRoomAvatar(
                              room: room,
                              isDirect: room.type == 1,
                              summary: AsyncValue.data(summariesData[room.id]),
                              validMembers: validMembers,
                              hideRealm: true,
                              radius: 16,
                            ),
                            Expanded(
                              child: Text(
                                getRoomTitle(room, validMembers),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (unread > 0)
                              Badge(
                                label: Text(unread.toString()),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                textColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                              ),
                          ],
                        ).padding(horizontal: 8),
                      );
                    }),
                  ],
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Badge(
                        isLabelVisible: totalUnread > 0,
                        label: Text(totalUnread.toString()),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        textColor: Theme.of(context).colorScheme.onPrimary,
                        child: buildRoundedRectAvatar(
                          ProfilePictureWidget(
                            file: realm?.picture,
                            radius: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          avatarTiles.addAll(
            groupedSections.ungroupedRooms.map((room) {
              return buildRoomIconButton(room);
            }),
          );
        } else {
          avatarTiles.addAll(
            filteredItems.map((room) {
              return buildRoomIconButton(room);
            }),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: avatarTiles.length,
          separatorBuilder: (_, _) => const Gap(8),
          itemBuilder: (_, index) => avatarTiles[index],
        );
      },
      loading: () => Center(
        child: ConfuseSpinner(
          size: 40,
          speed: 6,
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withOpacity(0.65),
        ),
      ),
      error: (error, stack) => IconButton(
        onPressed: () => ref.invalidate(chatRoomJoinedProvider),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}

class ChatListWidget extends HookConsumerWidget {
  final bool isAside;
  const ChatListWidget({super.key, this.isAside = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);
    final selectedTab = useState(
      0,
    ); // 0 for All, 1 for Direct Messages, 2 for Group Chats
    final lifecycleState = ref.watch(appLifecycleStateProvider);
    final previousLifecycleState = useRef<AppLifecycleState?>(null);
    final isResyncingAfterResume = useState(false);
    final userInfo = ref.watch(userInfoProvider);
    final accountId = userInfo.value?.id;
    final chatGroups =
        ref.watch(chatGroupsProvider).value ?? const <SnChatGroup>[];

    Future<void> refreshChatGroups() async {
      ref.invalidate(chatGroupsProvider);
    }

    Future<void> openInvitesSheet() async {
      await showModalBottomSheet(
        useRootNavigator: true,
        isScrollControlled: true,
        context: context,
        builder: (context) => const ChatInvitesSheet(),
      );
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
    final sidebarWidth = useState(320.0);
    final isCollapsed = useState(false);
    final isSidebarHovering = useState(false);
    const collapsedWidth = 64.0;
    const minSidebarWidth = 260.0;
    const maxSidebarWidth = 520.0;
    const collapseThreshold = 210.0;

    if (asideLayout) {
      final currentWidth = isCollapsed.value
          ? collapsedWidth
          : sidebarWidth.value;
      final chatInvites = ref.watch(chatroomInvitesProvider);

      return SizedBox(
        width: currentWidth,
        child: Card(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
              topLeft: Radius.circular(8),
            ),
          ),
          child: MouseRegion(
            onEnter: (_) => isSidebarHovering.value = true,
            onExit: (_) => isSidebarHovering.value = false,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Stack(
                children: [
                  if (isCollapsed.value)
                    Column(
                      children: [
                        Expanded(
                          child: _CollapsedChatListBody(
                            selectedTab: selectedTab,
                            chatGroups: chatGroups,
                            onChatGroupsChanged: refreshChatGroups,
                            accountId: accountId,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TabBar(
                                dividerColor: Colors.transparent,
                                controller: tabController,
                                tabAlignment: TabAlignment.start,
                                isScrollable: true,
                                tabs: [
                                  const Tab(icon: Icon(Symbols.chat)),
                                  const Tab(icon: Icon(Symbols.person)),
                                  const Tab(icon: Icon(Symbols.group)),
                                ],
                              ),
                            ),
                            const _MarkAllReadButton(),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: IconButton(
                                tooltip: 'Invites',
                                onPressed: openInvitesSheet,
                                icon: Badge(
                                  label: Text(
                                    chatInvites.when(
                                      data: (invites) =>
                                          invites.length.toString(),
                                      error: (_, _) => '0',
                                      loading: () => '0',
                                    ),
                                  ),
                                  isLabelVisible: chatInvites.when(
                                    data: (invites) => invites.isNotEmpty,
                                    error: (_, _) => false,
                                    loading: () => false,
                                  ),
                                  child: const Icon(Symbols.mail),
                                ),
                              ),
                            ),
                          ],
                        ).padding(horizontal: 8),
                        const Divider(height: 1),
                        Expanded(
                          child: ChatListBodyWidget(
                            isFloating: false,
                            tabController: tabController,
                            selectedTab: selectedTab,
                            chatGroups: chatGroups,
                            onChatGroupsChanged: refreshChatGroups,
                            accountId: accountId,
                          ),
                        ),
                      ],
                    ),
                  if (!isCollapsed.value)
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
                        onHorizontalDragEnd: (_) {
                          if (sidebarWidth.value <= collapseThreshold) {
                            isCollapsed.value = true;
                            sidebarWidth.value = minSidebarWidth;
                          }
                        },
                        onHorizontalDragUpdate: (details) {
                          if (isCollapsed.value) {
                            isCollapsed.value = false;
                            sidebarWidth.value = minSidebarWidth;
                          }
                          final next = (sidebarWidth.value + details.delta.dx)
                              .clamp(collapseThreshold, maxSidebarWidth);
                          sidebarWidth.value = next;
                        },
                        child: const SizedBox(width: 10),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      ignoring: !isSidebarHovering.value,
                      child: AnimatedOpacity(
                        opacity: isSidebarHovering.value ? 1 : 0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        child: AnimatedSlide(
                          offset: isSidebarHovering.value
                              ? Offset.zero
                              : const Offset(0.25, 0),
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          child: Center(
                            child: Material(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(10),
                              ),
                              child: IconButton(
                                constraints: const BoxConstraints.tightFor(
                                  width: 36,
                                  height: 36,
                                ),
                                padding: EdgeInsets.zero,
                                tooltip: isCollapsed.value
                                    ? 'Expand'
                                    : 'Collapse',
                                icon: Icon(
                                  isCollapsed.value
                                      ? Symbols.left_panel_open
                                      : Symbols.left_panel_close,
                                ),
                                onPressed: () =>
                                    isCollapsed.value = !isCollapsed.value,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      extendBody: false,
      floatingActionButton: const ChatFabWidget().padding(
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      appBar: AppBar(
        leading: null,
        flexibleSpace: Stack(
          children: [
            _ChatListAppBar(
              tabController: tabController,
              chatGroups: chatGroups,
              onChatGroupsChanged: refreshChatGroups,
              accountId: accountId,
            ),
          ],
        ),
      ),
      body: userInfo.value == null
          ? const ResponseUnauthorizedWidget()
          : ChatListBodyWidget(
              isFloating: false,
              tabController: tabController,
              selectedTab: selectedTab,
              chatGroups: chatGroups,
              onChatGroupsChanged: refreshChatGroups,
              accountId: accountId,
            ),
    );
  }
}
