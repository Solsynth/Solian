import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_pod.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/chat/widgets/chat_invites_sheet.dart';
import 'package:island/chat/widgets/chat_room_form.dart';
import 'package:island/chat/widgets/chat_room_list_tile.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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

    Widget bodyWidget = Column(
      children: [
        Consumer(
          builder: (context, ref, _) {
            final summaryState = ref.watch(chatSummaryProvider);
            return summaryState.maybeWhen(
              loading: () => const LinearProgressIndicator(
                minHeight: 2,
                borderRadius: BorderRadius.zero,
              ),
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
        Expanded(
          child: chats.when(
            data: (items) {
              final filteredItems = items.where(
                (item) =>
                    selectedTab.value == 0 ||
                    (selectedTab.value == 1 && item.type == 1) ||
                    (selectedTab.value == 2 && item.type != 1),
              );
              final pinnedItems = filteredItems
                  .where((item) => item.isPinned)
                  .toList();
              final unpinnedItems = filteredItems
                  .where((item) => !item.isPinned)
                  .toList();

              return ExtendedRefreshIndicator(
                onRefresh: () => Future.sync(() {
                  ref.invalidate(chatRoomJoinedProvider);
                }),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: Column(
                    children: [
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
                                onTap: () {
                                  if (isWideScreen(context)) {
                                    context.replaceNamed(
                                      'chatRoom',
                                      pathParameters: {'id': item.id},
                                    );
                                  } else {
                                    context.pushNamed(
                                      'chatRoom',
                                      pathParameters: {'id': item.id},
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, _) {
                            final summaries =
                                ref
                                    .watch(chatSummaryProvider)
                                    .whenData((data) => data)
                                    .value ??
                                {};

                            if (settings.groupedChatList &&
                                selectedTab.value == 0) {
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

                                // Calculate total unread count for this realm
                                final totalUnread = rooms.fold<int>(
                                  0,
                                  (sum, room) =>
                                      sum +
                                      (summaries[room.id]?.unreadCount ?? 0),
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
                                        onTap: () {
                                          if (isWideScreen(context)) {
                                            context.replaceNamed(
                                              'chatRoom',
                                              pathParameters: {'id': room.id},
                                            );
                                          } else {
                                            context.pushNamed(
                                              'chatRoom',
                                              pathParameters: {'id': room.id},
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
                                      onTap: () {
                                        if (isWideScreen(context)) {
                                          context.replaceNamed(
                                            'chatRoom',
                                            pathParameters: {'id': room.id},
                                          );
                                        } else {
                                          context.pushNamed(
                                            'chatRoom',
                                            pathParameters: {'id': room.id},
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
                              // Normal list view
                              return SuperListView.builder(
                                padding: EdgeInsets.only(bottom: 96),
                                itemCount: unpinnedItems
                                    .where(
                                      (item) =>
                                          selectedTab.value == 0 ||
                                          (selectedTab.value == 1 &&
                                              item.type == 1) ||
                                          (selectedTab.value == 2 &&
                                              item.type != 1),
                                    )
                                    .length,
                                itemBuilder: (context, index) {
                                  final item = unpinnedItems[index];
                                  return ChatRoomListTile(
                                    room: item,
                                    isDirect: item.type == 1,
                                    onTap: () {
                                      if (isWideScreen(context)) {
                                        context.replaceNamed(
                                          'chatRoom',
                                          pathParameters: {'id': item.id},
                                        );
                                      } else {
                                        context.pushNamed(
                                          'chatRoom',
                                          pathParameters: {'id': item.id},
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
            loading: () => const Center(child: CircularProgressIndicator()),
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

class ChatShellScreen extends HookConsumerWidget {
  final Widget child;
  const ChatShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    if (isWide) {
      return AppBackground(
        isRoot: true,
        child: SafeArea(
          child: Row(
            children: [
              Flexible(
                flex: 2,
                child: ChatListScreen(
                  isAside: true,
                  isFloating: true,
                ).padding(left: 16, vertical: 16),
              ),
              const Gap(8),
              Flexible(
                flex: 4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                  ),
                  child: child,
                ).padding(top: 16, right: 16),
              ),
            ],
          ),
        ),
      );
    }

    return AppBackground(isRoot: true, child: child);
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
    ).padding(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      right: 16,
    );
  }
}

class ChatListScreen extends HookConsumerWidget {
  final bool isAside;
  final bool isFloating;
  const ChatListScreen({
    super.key,
    this.isAside = false,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    final chatInvites = ref.watch(chatroomInvitesProvider);
    final tabController = useTabController(initialLength: 3);
    final selectedTab = useState(
      0,
    ); // 0 for All, 1 for Direct Messages, 2 for Group Chats

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

    if (isAside) {
      return Card(
        margin: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Stack(
            children: [
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
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
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
                          onPressed: () {
                            showModalBottomSheet(
                              useRootNavigator: true,
                              isScrollControlled: true,
                              context: context,
                              builder: (context) => const ChatInvitesSheet(),
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
              Positioned(bottom: 0, right: 0, child: ChatFabWidget()),
            ],
          ),
        ),
      );
    }

    if (isWide && !isAside) {
      return const EmptyPageHolder();
    }

    final appbarFeColor = Theme.of(context).appBarTheme.foregroundColor;

    final userInfo = ref.watch(userInfoProvider);

    return AppScaffold(
      extendBody: false, // Prevent conflicts with tabs navigation
      floatingActionButton: const ChatFabWidget(),
      appBar: AppBar(
        flexibleSpace: Container(
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
