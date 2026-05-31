import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/chat/pods/chat_account_status.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:island/chat/pods/chat_summary.dart';
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
import 'package:island/data/database.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
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

class _ChatGroupIconOption {
  const _ChatGroupIconOption(this.id, this.icon);

  final String id;
  final IconData icon;
}

enum _ChatToolbarMenuAction { invites, groups }

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

const List<String> _chatGroupColorOptions = <String>[
  '#4A90D9',
  '#7ED321',
  '#F5A623',
  '#E35D6A',
  '#8B5CF6',
  '#14B8A6',
];

const List<_ChatGroupIconOption> _chatGroupIconOptions = <_ChatGroupIconOption>[
  _ChatGroupIconOption('folder', Symbols.folder),
  _ChatGroupIconOption('work', Symbols.work),
  _ChatGroupIconOption('favorite', Symbols.favorite),
  _ChatGroupIconOption('forum', Symbols.forum),
  _ChatGroupIconOption('school', Symbols.school),
  _ChatGroupIconOption('bolt', Symbols.bolt),
];

Color? _chatGroupColorFromHex(String? value) {
  if (value == null || value.isEmpty) return null;
  final normalized = value.replaceFirst('#', '');
  final hex = switch (normalized.length) {
    6 => 'FF$normalized',
    8 => normalized,
    _ => '',
  };
  if (hex.isEmpty) return null;
  return Color(int.tryParse(hex, radix: 16) ?? 0xFF9E9E9E);
}

IconData _chatGroupIconData(String? value) {
  for (final option in _chatGroupIconOptions) {
    if (option.id == value) return option.icon;
  }
  return Symbols.folder;
}

bool _chatGroupIconIsPreset(String? value) {
  if (value == null || value.isEmpty) return false;
  return _chatGroupIconOptions.any((option) => option.id == value);
}

Widget _buildChatGroupIconWidget(
  String? value, {
  Color? color,
  double iconSize = 20,
  double emojiFontSize = 18,
}) {
  if (value != null && value.isNotEmpty && !_chatGroupIconIsPreset(value)) {
    return Text(
      value,
      style: TextStyle(fontSize: emojiFontSize, height: 1),
      textAlign: TextAlign.center,
    ).padding(left: 3);
  }
  return Icon(_chatGroupIconData(value), color: color, size: iconSize);
}

List<SnChatGroup> _normalizeChatGroups(List<SnChatGroup> groups) {
  final sorted = groups.toList()..sort((a, b) => a.order.compareTo(b.order));
  return [for (var i = 0; i < sorted.length; i++) sorted[i].copyWith(order: i)];
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

final chatGroupsProvider = FutureProvider<List<SnChatGroup>>((ref) async {
  final db = ref.watch(databaseProvider);
  final userInfo = ref.watch(userInfoProvider);
  final accountId = userInfo.value?.id;
  if (accountId == null) return const <SnChatGroup>[];
  return db.getChatGroups(accountId);
});

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

    Widget buildRoomTile(SnChatRoom room) {
      return ContextMenuWidget(
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
                    final changedGroup = await _showAssignChatGroupSheet(
                      context,
                      client: client,
                      db: db,
                      accountId: accountId!,
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
          onTap: () {
            if (isWideScreen(context)) {
              context.router.navigate(ChatRoomRoute(id: room.id));
            } else {
              context.router.push(ChatRoomRoute(id: room.id));
            }
          },
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
              final pinnedItems = useMemoized(
                () => filteredItems.where((item) => item.isPinned).toList(),
                [filteredItems],
              );
              final unpinnedItems = useMemoized(
                () => filteredItems.where((item) => !item.isPinned).toList(),
                [filteredItems],
              );
              final groupedSections = useMemoized(
                () => _buildGroupedChatSections(
                  unpinnedItems,
                  chatGroups,
                  summariesData,
                ),
                [unpinnedItems, chatGroups, summariesData],
              );

              return ExtendedRefreshIndicator(
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
                      // Always show pinned chats in their own section
                      if (pinnedItems.isNotEmpty)
                        ExpansionTile(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.5),
                          collapsedBackgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainer.withOpacity(0.5),
                          title: Text('pinnedChatRoom'.tr()),
                          leading: const Icon(Symbols.keep, fill: 1),
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          initiallyExpanded: true,
                          children: [
                            for (final item in pinnedItems) buildRoomTile(item),
                          ],
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
                                    _chatGroupColorFromHex(
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
                                      child: _buildChatGroupIconWidget(
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
    final db = ref.watch(databaseProvider);
    final client = ref.watch(apiClientProvider);

    Future<void> openInvites() async {
      await showModalBottomSheet(
        useRootNavigator: true,
        isScrollControlled: true,
        context: context,
        builder: (context) => const ChatInvitesSheet(),
      );
    }

    Future<void> openGroups() async {
      final currentAccountId = accountId;
      if (currentAccountId == null) return;
      final changed = await _showChatGroupsManagerSheet(
        context,
        client: client,
        db: db,
        accountId: currentAccountId,
        groups: chatGroups,
      );
      if (changed) {
        await onChatGroupsChanged();
      }
    }

    PopupMenuButton<_ChatToolbarMenuAction> buildToolbarMenu() {
      return PopupMenuButton<_ChatToolbarMenuAction>(
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
          child: const Icon(Symbols.email),
        ),
        color: appbarFeColor,
        onSelected: (value) async {
          if (value == _ChatToolbarMenuAction.invites) {
            await openInvites();
          } else {
            await openGroups();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _ChatToolbarMenuAction.invites,
            child: Text('Chat Invites'),
          ),
          PopupMenuItem(
            value: _ChatToolbarMenuAction.groups,
            child: Text('Chat Groups'),
          ),
        ],
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
            buildToolbarMenu(),
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : const Icon(Symbols.done_all),
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

int _nextChatGroupOrder(List<SnChatGroup> groups) {
  if (groups.isEmpty) return 0;
  return groups.map((group) => group.order).reduce(math.max) + 1;
}

String _createChatGroupId() {
  return 'local-chat-group-${DateTime.now().toUtc().microsecondsSinceEpoch}';
}

List<SnChatGroup> _upsertChatGroup(
  List<SnChatGroup> groups,
  SnChatGroup group,
) {
  final next = groups.where((item) => item.id != group.id).toList()..add(group);
  return _normalizeChatGroups(next);
}

List<SnChatGroup> _removeChatGroup(List<SnChatGroup> groups, String groupId) {
  return _normalizeChatGroups(
    groups.where((item) => item.id != groupId).toList(),
  );
}

List<SnChatGroup> _applyRoomGroupAssignment(
  List<SnChatGroup> groups,
  String roomId, {
  String? groupId,
}) {
  return _normalizeChatGroups(
    groups.map((group) {
      final nextRoomIds = group.roomIds.where((id) => id != roomId).toList();
      if (group.id == groupId) nextRoomIds.add(roomId);
      return group.copyWith(roomIds: nextRoomIds);
    }).toList(),
  );
}

Future<SnChatGroup?> _showChatGroupEditorSheet(
  BuildContext context, {
  required String accountId,
  SnChatGroup? initialGroup,
  required int nextOrder,
}) async {
  final nameController = TextEditingController(text: initialGroup?.name ?? '');
  final iconController = TextEditingController(text: initialGroup?.icon ?? '');
  var selectedColor = initialGroup?.color ?? _chatGroupColorOptions.first;
  var selectedIcon = initialGroup?.icon ?? '';

  return showModalBottomSheet<SnChatGroup>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SheetScaffold(
            titleText: initialGroup == null ? 'Create Group' : 'Edit Group',
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    maxLength: 256,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const Gap(12),
                  TextField(
                    controller: iconController,
                    maxLength: 8,
                    decoration: const InputDecoration(
                      labelText: 'Icon or emoji',
                      hintText: '📁',
                    ),
                    onChanged: (value) => selectedIcon = value.trim(),
                  ),
                  const Gap(12),
                  Text('Color', style: Theme.of(context).textTheme.titleSmall),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final color in _chatGroupColorOptions)
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () =>
                              setModalState(() => selectedColor = color),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _chatGroupColorFromHex(color),
                              border: Border.all(
                                color: selectedColor == color
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: selectedColor == color
                                ? Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                  const Gap(20),
                  FilledButton(
                    onPressed: () {
                      final trimmedName = nameController.text.trim();
                      if (trimmedName.isEmpty) return;
                      final now = DateTime.now().toUtc();
                      Navigator.of(context).pop(
                        SnChatGroup(
                          id: initialGroup?.id ?? _createChatGroupId(),
                          accountId: accountId,
                          name: trimmedName,
                          color: selectedColor,
                          icon: selectedIcon,
                          order: initialGroup?.order ?? nextOrder,
                          roomIds: initialGroup?.roomIds ?? const [],
                          createdAt: initialGroup?.createdAt ?? now,
                          updatedAt: now,
                        ),
                      );
                    },
                    child: Text(initialGroup == null ? 'Create' : 'Save'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<bool> _showChatGroupsManagerSheet(
  BuildContext context, {
  required Dio client,
  required AppDatabase db,
  required String accountId,
  required List<SnChatGroup> groups,
}) async {
  var currentGroups = _normalizeChatGroups(groups);
  var changed = false;

  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> persist(List<SnChatGroup> nextGroups) async {
            currentGroups = _normalizeChatGroups(nextGroups);
            await db.saveChatGroups(accountId, currentGroups);
            changed = true;
            setModalState(() {});
          }

          return SheetScaffold(
            titleText: 'Chat Groups',
            actions: [
              IconButton(
                icon: const Icon(Symbols.add),
                onPressed: () async {
                  final group = await _showChatGroupEditorSheet(
                    context,
                    accountId: accountId,
                    nextOrder: _nextChatGroupOrder(currentGroups),
                  );
                  if (group == null) return;
                  final response = await client.post(
                    '/messager/chat/groups',
                    data: {
                      'name': group.name,
                      'color': group.color,
                      'icon': group.icon,
                      'order': group.order,
                    }..removeWhere((_, value) => value == null),
                  );
                  final created = SnChatGroup.fromJson(
                    Map<String, dynamic>.from(response.data as Map),
                  );
                  await persist(_upsertChatGroup(currentGroups, created));
                },
              ),
            ],
            child: currentGroups.isEmpty
                ? const Center(child: Text('No chat groups yet'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: currentGroups.length,
                    itemBuilder: (context, index) {
                      final group = currentGroups[index];
                      final groupColor =
                          _chatGroupColorFromHex(group.color) ??
                          Theme.of(context).colorScheme.primary;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: groupColor.withOpacity(0.16),
                          foregroundColor: groupColor,
                          child: _buildChatGroupIconWidget(
                            group.icon,
                            color: groupColor,
                          ),
                        ),
                        title: Text(group.name),
                        subtitle: Text(
                          '${group.roomIds.length} room${group.roomIds.length == 1 ? '' : 's'}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              onPressed: index == 0
                                  ? null
                                  : () async {
                                      final next = currentGroups.toList();
                                      final temp = next[index - 1];
                                      next[index - 1] = next[index];
                                      next[index] = temp;
                                      final normalized = _normalizeChatGroups(
                                        next,
                                      );
                                      for (final group in normalized) {
                                        await client.patch(
                                          '/messager/chat/groups/${group.id}',
                                          data: {'order': group.order},
                                        );
                                      }
                                      await persist(normalized);
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward),
                              onPressed: index == currentGroups.length - 1
                                  ? null
                                  : () async {
                                      final next = currentGroups.toList();
                                      final temp = next[index + 1];
                                      next[index + 1] = next[index];
                                      next[index] = temp;
                                      final normalized = _normalizeChatGroups(
                                        next,
                                      );
                                      for (final group in normalized) {
                                        await client.patch(
                                          '/messager/chat/groups/${group.id}',
                                          data: {'order': group.order},
                                        );
                                      }
                                      await persist(normalized);
                                    },
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final edited =
                                      await _showChatGroupEditorSheet(
                                        context,
                                        accountId: accountId,
                                        initialGroup: group,
                                        nextOrder: group.order,
                                      );
                                  if (edited == null) return;
                                  final response = await client.patch(
                                    '/messager/chat/groups/${group.id}',
                                    data: {
                                      'name': edited.name,
                                      'color': edited.color,
                                      'icon': edited.icon,
                                      'order': edited.order,
                                    }..removeWhere((_, value) => value == null),
                                  );
                                  final updated = SnChatGroup.fromJson(
                                    Map<String, dynamic>.from(
                                      response.data as Map,
                                    ),
                                  );
                                  await persist(
                                    _upsertChatGroup(currentGroups, updated),
                                  );
                                  return;
                                }
                                if (value == 'delete') {
                                  await client.delete(
                                    '/messager/chat/groups/${group.id}',
                                  );
                                  await persist(
                                    _removeChatGroup(currentGroups, group.id),
                                  );
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
        },
      );
    },
  );

  return changed;
}

Future<bool> _showAssignChatGroupSheet(
  BuildContext context, {
  required Dio client,
  required AppDatabase db,
  required String accountId,
  required SnChatRoom room,
  required List<SnChatGroup> groups,
}) async {
  SnChatGroup? currentGroup;
  for (final group in groups) {
    if (group.roomIds.contains(room.id)) {
      currentGroup = group;
      break;
    }
  }

  var changed = false;
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) {
      return SheetScaffold(
        heightFactor: 0.6,
        titleText: 'Move To Group',
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 16,
                child: const Icon(Symbols.do_not_disturb_on),
              ),
              title: const Text('Ungrouped'),
              trailing: currentGroup == null ? const Icon(Icons.check) : null,
              onTap: () async {
                await client.patch(
                  '/messager/chat/rooms/${room.id}/group',
                  data: {'group_id': null},
                );
                await db.saveChatGroups(
                  accountId,
                  _applyRoomGroupAssignment(groups, room.id),
                );
                changed = true;
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
            for (final group in _normalizeChatGroups(groups))
              ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      (_chatGroupColorFromHex(group.color) ??
                              Theme.of(context).colorScheme.primary)
                          .withOpacity(0.16),
                  foregroundColor:
                      _chatGroupColorFromHex(group.color) ??
                      Theme.of(context).colorScheme.primary,
                  child: _buildChatGroupIconWidget(
                    group.icon,
                    color:
                        _chatGroupColorFromHex(group.color) ??
                        Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(group.name),
                trailing: currentGroup?.id == group.id
                    ? const Icon(Icons.check)
                    : null,
                onTap: () async {
                  await client.patch(
                    '/messager/chat/rooms/${room.id}/group',
                    data: {'group_id': group.id},
                  );
                  await db.saveChatGroups(
                    accountId,
                    _applyRoomGroupAssignment(
                      groups,
                      room.id,
                      groupId: group.id,
                    ),
                  );
                  changed = true;
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
              ),
            ListTile(
              leading: CircleAvatar(radius: 16, child: const Icon(Symbols.add)),
              title: const Text('Create New Group'),
              onTap: () async {
                final created = await _showChatGroupEditorSheet(
                  context,
                  accountId: accountId,
                  nextOrder: _nextChatGroupOrder(groups),
                );
                if (created == null) return;
                final createdResp = await client.post(
                  '/messager/chat/groups',
                  data: {
                    'name': created.name,
                    'color': created.color,
                    'icon': created.icon,
                    'order': created.order,
                  }..removeWhere((_, value) => value == null),
                );
                final createdGroup = SnChatGroup.fromJson(
                  Map<String, dynamic>.from(createdResp.data as Map),
                );
                await client.patch(
                  '/messager/chat/rooms/${room.id}/group',
                  data: {'group_id': createdGroup.id},
                );
                await db.saveChatGroups(
                  accountId,
                  _applyRoomGroupAssignment(
                    _upsertChatGroup(groups, createdGroup),
                    room.id,
                    groupId: createdGroup.id,
                  ),
                );
                changed = true;
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
  return changed;
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

    void openRoom(String roomId) {
      if (isWideScreen(context)) {
        context.router.navigate(ChatRoomRoute(id: roomId));
      } else {
        context.router.push(ChatRoomRoute(id: roomId));
      }
    }

    List<SnChatMember> getValidMembers(SnChatRoom room) {
      var validMembers = room.members ?? <SnChatMember>[];
      if (validMembers.isNotEmpty && userInfo.value != null) {
        validMembers = validMembers
            .where((e) => e.accountId != userInfo.value!.id)
            .toList();
      }
      return validMembers;
    }

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

    Widget withSelectedDot({required Widget child, required bool isSelected}) {
      return SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                left: 2,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            Center(child: child),
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
          final validMembers = getValidMembers(room);
          final title = getRoomTitle(room, validMembers);
          return withSelectedDot(
            isSelected: activeChatId == room.id,
            child: ContextMenuWidget(
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
                          final changedGroup = await _showAssignChatGroupSheet(
                            context,
                            client: client,
                            db: db,
                            accountId: accountId!,
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
              child: IconButton(
                tooltip: title,
                onPressed: () => openRoom(room.id),
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
                _chatGroupColorFromHex(section.group.color) ??
                Theme.of(context).colorScheme.primary;
            avatarTiles.add(
              withSelectedDot(
                isSelected: rooms.any((room) => room.id == activeChatId),
                child: PopupMenuButton<SnChatRoom>(
                  tooltip: section.group.name,
                  position: PopupMenuPosition.under,
                  onSelected: (room) => openRoom(room.id),
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
                            child: _buildChatGroupIconWidget(
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
                      final validMembers = getValidMembers(room);
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
                              child: _buildChatGroupIconWidget(
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
              withSelectedDot(
                isSelected: rooms.any((room) => room.id == activeChatId),
                child: PopupMenuButton<SnChatRoom>(
                  tooltip: realm?.name ?? 'Group',
                  position: PopupMenuPosition.under,
                  onSelected: (room) => openRoom(room.id),
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
                      final validMembers = getValidMembers(room);
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
    final db = ref.watch(databaseProvider);
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

    Future<void> openGroupsSheet() async {
      if (accountId == null) return;
      final client = ref.read(apiClientProvider);
      final changed = await _showChatGroupsManagerSheet(
        context,
        client: client,
        db: db,
        accountId: accountId,
        groups: chatGroups,
      );
      if (changed) {
        await refreshChatGroups();
      }
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
                              child: PopupMenuButton<_ChatToolbarMenuAction>(
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
                                  child: const Icon(Symbols.action_key),
                                ),
                                onSelected: (value) async {
                                  if (value == _ChatToolbarMenuAction.invites) {
                                    await openInvitesSheet();
                                  } else {
                                    await openGroupsSheet();
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: _ChatToolbarMenuAction.invites,
                                    child: Row(
                                      children: [
                                        Icon(Symbols.person_add),
                                        Gap(12),
                                        Text('Invites'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: _ChatToolbarMenuAction.groups,
                                    child: Row(
                                      children: [
                                        Icon(Symbols.group),
                                        Gap(12),
                                        Text('Groups'),
                                      ],
                                    ),
                                  ),
                                ],
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
