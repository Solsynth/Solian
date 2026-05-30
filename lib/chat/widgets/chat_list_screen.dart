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
import 'package:island/core/lifecycle.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/response.dart';

import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
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

class ChatListBodyWidget extends HookConsumerWidget {
  final bool isFloating;
  final TabController tabController;
  final ValueNotifier<int> selectedTab;

  const ChatListBodyWidget({
    super.key,
    this.isFloating = false,
    required this.tabController,
    required this.selectedTab,
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
                            for (final item in pinnedItems)
                              ChatRoomListTile(
                                room: item,
                                isDirect: item.type == 1,
                                selected: activeChatId == item.id,
                                pushNotificationsSuppressed:
                                    accountStatus
                                        .whenData((data) => data)
                                        .value
                                        ?.isPushNotificationsSuppressed(
                                          item.id,
                                        ) ??
                                    false,
                                onTap: () {
                                  if (isWideScreen(context)) {
                                    context.router.navigate(
                                      ChatRoomRoute(id: item.id),
                                    );
                                  } else {
                                    context.router.push(
                                      ChatRoomRoute(id: item.id),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (settings.groupedChatList &&
                                selectedTabValue == 0) {
                              // Group by realm (include both pinned and unpinned)
                              final realmGroups = <String?, List<SnChatRoom>>{};
                              final ungrouped = <SnChatRoom>[];

                              for (final item in filteredItems) {
                                if (item.realmId != null) {
                                  realmGroups
                                      .putIfAbsent(item.realmId, () => [])
                                      .add(item);
                                } else if (!item.isPinned) {
                                  // Only unpinned chats without realm go to ungrouped
                                  ungrouped.add(item);
                                }
                              }

                              final children = <Widget>[];

                              // Add realm groups
                              for (final entry in realmGroups.entries) {
                                final rooms = entry.value;
                                final realm = rooms.first.realm;
                                final realmName =
                                    realm?.name ?? 'Unknown Realm';

                                final totalUnread = rooms.fold<int>(
                                  0,
                                  (sum, room) =>
                                      sum +
                                      (summariesData[room.id]?.unreadCount ??
                                          0),
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
                                    children: rooms.map((room) {
                                      return ChatRoomListTile(
                                        room: room,
                                        isDirect: room.type == 1,
                                        selected: activeChatId == room.id,
                                        pushNotificationsSuppressed:
                                            accountStatus
                                                .whenData((data) => data)
                                                .value
                                                ?.isPushNotificationsSuppressed(
                                                  room.id,
                                                ) ??
                                            false,
                                        onTap: () {
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
                                      );
                                    }).toList(),
                                  ),
                                );
                              }

                              // Add ungrouped chats
                              if (ungrouped.isNotEmpty) {
                                children.addAll(
                                  ungrouped.map((room) {
                                    return ChatRoomListTile(
                                      room: room,
                                      isDirect: room.type == 1,
                                      selected: activeChatId == room.id,
                                      pushNotificationsSuppressed:
                                          accountStatus
                                              .whenData((data) => data)
                                              .value
                                              ?.isPushNotificationsSuppressed(
                                                room.id,
                                              ) ??
                                          false,
                                      onTap: () {
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
                                    );
                                  }),
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
                                  return ChatRoomListTile(
                                    room: item,
                                    isDirect: item.type == 1,
                                    selected: activeChatId == item.id,
                                    pushNotificationsSuppressed:
                                        accountStatus
                                            .whenData((data) => data)
                                            .value
                                            ?.isPushNotificationsSuppressed(
                                              item.id,
                                            ) ??
                                        false,
                                    onTap: () {
                                      if (isWideScreen(context)) {
                                        context.router.navigate(
                                          ChatRoomRoute(id: item.id),
                                        );
                                      } else {
                                        context.router.push(
                                          ChatRoomRoute(id: item.id),
                                        );
                                      }
                                    },
                                  );
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

  const _ChatListAppBar({required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatInvites = ref.watch(chatroomInvitesProvider);
    final isSyncing = ref.watch(chatSyncingProvider);
    final appbarFeColor = Theme.of(context).appBarTheme.foregroundColor;

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
            IconButton(
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
              onPressed: () {
                showModalBottomSheet(
                  useRootNavigator: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => const ChatInvitesSheet(),
                );
              },
            ),
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

class _CollapsedChatListBody extends HookConsumerWidget {
  final ValueNotifier<int> selectedTab;

  const _CollapsedChatListBody({required this.selectedTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatRoomJoinedProvider);
    final settings = ref.watch(appSettingsProvider);
    final summaries = ref.watch(chatSummaryProvider);
    final userInfo = ref.watch(userInfoProvider);
    final activeChatId = ref.watch(currentSubscribedChatIdProvider);

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

        final avatarTiles = <Widget>[];
        if (settings.groupedChatList && selectedTabValue == 0) {
          final realmGroups = <String?, List<SnChatRoom>>{};
          final ungrouped = <SnChatRoom>[];

          for (final item in filteredItems) {
            if (item.realmId != null) {
              realmGroups.putIfAbsent(item.realmId, () => []).add(item);
            } else {
              ungrouped.add(item);
            }
          }

          for (final rooms in realmGroups.values) {
            final realm = rooms.first.realm;
            final totalUnread = rooms.fold<int>(
              0,
              (sum, room) => sum + (summariesData[room.id]?.unreadCount ?? 0),
            );
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
            ungrouped.map((room) {
              final unread = summariesData[room.id]?.unreadCount ?? 0;
              final validMembers = getValidMembers(room);
              final title = getRoomTitle(room, validMembers);
              return withSelectedDot(
                isSelected: activeChatId == room.id,
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
              );
            }),
          );
        } else {
          avatarTiles.addAll(
            filteredItems.map((room) {
              final unread = summariesData[room.id]?.unreadCount ?? 0;
              final validMembers = getValidMembers(room);
              final title = getRoomTitle(room, validMembers);
              return withSelectedDot(
                isSelected: activeChatId == room.id,
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
              );
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

    useEffect(() {
      tabController.addListener(() {
        selectedTab.value = tabController.index;
      });

      // Listen for chat rooms refresh events
      final subscription = eventBus.on<ChatRoomsRefreshEvent>().listen((event) {
        ref.invalidate(chatRoomJoinedProvider);
      });

      return () {
        subscription.cancel();
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
                                  child: const Icon(Symbols.email),
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    useRootNavigator: true,
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) =>
                                        const ChatInvitesSheet(),
                                  );
                                },
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

    final userInfo = ref.watch(userInfoProvider);

    return AppScaffold(
      extendBody: false,
      floatingActionButton: const ChatFabWidget().padding(
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      appBar: AppBar(
        leading: null,
        flexibleSpace: Stack(
          children: [_ChatListAppBar(tabController: tabController)],
        ),
      ),
      body: userInfo.value == null
          ? const ResponseUnauthorizedWidget()
          : ChatListBodyWidget(
              isFloating: false,
              tabController: tabController,
              selectedTab: selectedTab,
            ),
    );
  }
}
