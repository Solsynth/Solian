import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/chat.dart';
import 'package:island/pods/chat/chat_summary.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/realm/realms.dart';
import 'package:island/services/event_bus.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/chat_room_widgets.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/navigation/fab_menu.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:island/pods/chat/chat_room.dart';

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
            data: (items) => RefreshIndicator(
              onRefresh: () => Future.sync(() {
                ref.invalidate(chatRoomJoinedProvider);
              }),
              child: SuperListView.builder(
                padding: EdgeInsets.only(bottom: 96),
                itemCount: items
                    .where(
                      (item) =>
                          selectedTab.value == 0 ||
                          (selectedTab.value == 1 && item.type == 1) ||
                          (selectedTab.value == 2 && item.type != 1),
                    )
                    .length,
                itemBuilder: (context, index) {
                  final filteredItems = items
                      .where(
                        (item) =>
                            selectedTab.value == 0 ||
                            (selectedTab.value == 1 && item.type == 1) ||
                            (selectedTab.value == 2 && item.type != 1),
                      )
                      .toList();
                  final item = filteredItems[index];
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
              ),
            ),
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
              ).padding(top: 16),
            ),
          ],
        ),
      );
    }

    return AppBackground(isRoot: true, child: child);
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

    useEffect(() {
      // Set FAB type to chat
      final fabMenuNotifier = ref.read(fabMenuTypeProvider.notifier);
      Future(() {
        fabMenuNotifier.setMenuType(FabMenuType.chat);
      });
      return () {
        // Clean up: reset FAB type to main
        final fabMenu = ref.read(fabMenuTypeProvider);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (fabMenu == FabMenuType.chat) {
            fabMenuNotifier.setMenuType(FabMenuType.main);
          }
        });
      };
    }, []);

    if (isAside) {
      return Card(
        margin: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Column(
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
                          builder: (context) => const _ChatInvitesSheet(),
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
        ),
      );
    }

    if (isWide && !isAside) {
      return const EmptyPageHolder();
    }

    final appbarFeColor = Theme.of(context).appBarTheme.foregroundColor;

    return AppScaffold(
      extendBody: false, // Prevent conflicts with tabs navigation
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
                      builder: (context) => const _ChatInvitesSheet(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: ChatListBodyWidget(
        isFloating: false,
        tabController: tabController,
        selectedTab: selectedTab,
      ),
    );
  }
}

class _ChatInvitesSheet extends HookConsumerWidget {
  const _ChatInvitesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = ref.watch(chatroomInvitesProvider);

    Future<void> acceptInvite(SnChatMember invite) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post('/sphere/chat/invites/${invite.chatRoom!.id}/accept');
        ref.invalidate(chatroomInvitesProvider);
        ref.invalidate(chatRoomJoinedProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> declineInvite(SnChatMember invite) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/sphere/chat/invites/${invite.chatRoom!.id}/decline',
        );
        ref.invalidate(chatroomInvitesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: 'invites'.tr(),
      actions: [
        IconButton(
          icon: const Icon(Symbols.refresh),
          style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          onPressed: () {
            ref.invalidate(realmInvitesProvider);
          },
        ),
      ],
      child: invites.when(
        data: (items) => items.isEmpty
            ? Center(
                child: Text('invitesEmpty', textAlign: TextAlign.center).tr(),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final invite = items[index];
                  return ChatRoomListTile(
                    room: invite.chatRoom!,
                    isDirect: invite.chatRoom!.type == 1,
                    subtitle: Row(
                      spacing: 6,
                      children: [
                        if (invite.chatRoom!.type == 1)
                          Badge(
                            label: const Text('directMessage').tr(),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            textColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Symbols.check),
                          onPressed: () => acceptInvite(invite),
                        ),
                        IconButton(
                          icon: const Icon(Symbols.close),
                          onPressed: () => declineInvite(invite),
                        ),
                      ],
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class ChatRoomListTile extends HookConsumerWidget {
  final SnChatRoom room;
  final bool isDirect;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ChatRoomListTile({
    super.key,
    required this.room,
    this.isDirect = false,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref
        .watch(chatSummaryProvider)
        .whenData((summaries) => summaries[room.id]);

    var validMembers = room.members ?? [];
    if (validMembers.isNotEmpty) {
      final userInfo = ref.watch(userInfoProvider);
      if (userInfo.value != null) {
        validMembers = validMembers
            .where((e) => e.accountId != userInfo.value!.id)
            .toList();
      }
    }

    String titleText;
    if (isDirect && room.name == null) {
      if (room.members?.isNotEmpty ?? false) {
        titleText = validMembers.map((e) => e.account.nick).join(', ');
      } else {
        titleText = 'Direct Message';
      }
    } else {
      titleText = room.name ?? '';
    }

    return ListTile(
      leading: ChatRoomAvatar(
        room: room,
        isDirect: isDirect,
        summary: summary,
        validMembers: validMembers,
      ),
      title: Text(titleText),
      subtitle: ChatRoomSubtitle(
        room: room,
        isDirect: isDirect,
        validMembers: validMembers,
        summary: summary,
        subtitle: subtitle,
      ),
      trailing: trailing, // Add this line
      onTap: () async {
        // Clear unread count if there are unread messages
        ref.read(chatSummaryProvider.future).then((summary) {
          if ((summary[room.id]?.unreadCount ?? 0) > 0) {
            ref.read(chatSummaryProvider.notifier).clearUnreadCount(room.id);
          }
        });
        onTap?.call();
      },
    );
  }
}
