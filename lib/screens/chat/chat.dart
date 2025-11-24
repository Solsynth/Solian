import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/chat.dart';
import 'package:island/models/file.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/database.dart';
import 'package:island/pods/chat/chat_summary.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/realm/realms.dart';
import 'package:island/services/event_bus.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/navigation/fab_menu.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:relative_time/relative_time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

part 'chat.g.dart';

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
        validMembers =
            validMembers
                .where((e) => e.accountId != userInfo.value!.id)
                .toList();
      }
    }

    Widget buildSubtitle() {
      if (subtitle != null) return subtitle!;

      return summary.when(
        data: (data) {
          if (data == null) {
            return isDirect && room.description == null
                ? Text(
                  validMembers.map((e) => '@${e.account.name}').join(', '),
                  maxLines: 1,
                )
                : Text(room.description ?? 'descriptionNone'.tr(), maxLines: 1);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (data.unreadCount > 0)
                Text(
                  'unreadMessages'.plural(data.unreadCount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              if (data.lastMessage == null)
                Text(room.description ?? 'descriptionNone'.tr(), maxLines: 1)
              else
                Row(
                  spacing: 4,
                  children: [
                    Badge(
                      label: Text(data.lastMessage!.sender.account.nick),
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    Expanded(
                      child: Text(
                        (data.lastMessage!.content?.isNotEmpty ?? false)
                            ? data.lastMessage!.content!
                            : 'messageNone'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        RelativeTime(
                          context,
                        ).format(data.lastMessage!.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error:
            (_, _) =>
                isDirect && room.description == null
                    ? Text(
                      validMembers.map((e) => '@${e.account.name}').join(', '),
                      maxLines: 1,
                    )
                    : Text(
                      room.description ?? 'descriptionNone'.tr(),
                      maxLines: 1,
                    ),
      );
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
      leading: Badge(
        isLabelVisible: summary.when(
          data: (data) => (data?.unreadCount ?? 0) > 0,
          loading: () => false,
          error: (_, _) => false,
        ),
        child:
            (isDirect && room.picture?.id == null)
                ? SplitAvatarWidget(
                  filesId:
                      validMembers
                          .map((e) => e.account.profile.picture?.id)
                          .toList(),
                )
                : room.picture?.id == null
                ? CircleAvatar(child: Text(room.name![0].toUpperCase()))
                : ProfilePictureWidget(fileId: room.picture?.id),
      ),
      title: Text(titleText),
      subtitle: buildSubtitle(),
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

@riverpod
Future<List<SnChatRoom>> chatroomsJoined(Ref ref) async {
  final db = ref.watch(databaseProvider);

  try {
    final localRoomsData = await db.select(db.chatRooms).get();
    if (localRoomsData.isNotEmpty) {
      final localRooms = await Future.wait(
        localRoomsData.map((row) async {
          final membersRows =
              await (db.select(db.chatMembers)
                ..where((m) => m.chatRoomId.equals(row.id))).get();
          final members =
              membersRows.map((mRow) {
                final account = SnAccount.fromJson(mRow.account);
                SnAccountStatus? status;
                if (mRow.status != null) {
                  status = SnAccountStatus.fromJson(jsonDecode(mRow.status!));
                }
                return SnChatMember(
                  id: mRow.id,
                  chatRoomId: mRow.chatRoomId,
                  accountId: mRow.accountId,
                  account: account,
                  nick: mRow.nick,
                  role: mRow.role,
                  notify: mRow.notify,
                  joinedAt: mRow.joinedAt,
                  breakUntil: mRow.breakUntil,
                  timeoutUntil: mRow.timeoutUntil,
                  isBot: mRow.isBot,
                  status: status,
                  lastTyped: mRow.lastTyped,
                  createdAt: mRow.createdAt,
                  updatedAt: mRow.updatedAt,
                  deletedAt: mRow.deletedAt,
                  chatRoom: null,
                );
              }).toList();
          return SnChatRoom(
            id: row.id,
            name: row.name,
            description: row.description,
            type: row.type,
            isPublic: row.isPublic!,
            isCommunity: row.isCommunity!,
            picture:
                row.picture != null ? SnCloudFile.fromJson(row.picture!) : null,
            background:
                row.background != null
                    ? SnCloudFile.fromJson(row.background!)
                    : null,
            realmId: row.realmId,
            realm: null,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
            deletedAt: row.deletedAt,
            members: members,
          );
        }),
      );

      // Background sync
      Future(() async {
        try {
          final client = ref.read(apiClientProvider);
          final resp = await client.get('/sphere/chat');
          final remoteRooms =
              resp.data
                  .map((e) => SnChatRoom.fromJson(e))
                  .cast<SnChatRoom>()
                  .toList();
          await db.saveChatRooms(remoteRooms);
          ref.invalidateSelf();
        } catch (_) {}
      }).ignore();

      return localRooms;
    }
  } catch (_) {}

  // Fallback to API
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/chat');
  final rooms =
      resp.data.map((e) => SnChatRoom.fromJson(e)).cast<SnChatRoom>().toList();
  await db.saveChatRooms(rooms);
  return rooms;
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
    final chats = ref.watch(chatroomsJoinedProvider);

    Widget bodyWidget = Column(
      children: [
        Consumer(
          builder: (context, ref, _) {
            final summaryState = ref.watch(chatSummaryProvider);
            return summaryState.maybeWhen(
              loading:
                  () => const LinearProgressIndicator(
                    minHeight: 2,
                    borderRadius: BorderRadius.zero,
                  ),
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
        Expanded(
          child: chats.when(
            data:
                (items) => RefreshIndicator(
                  onRefresh:
                      () => Future.sync(() {
                        ref.invalidate(chatroomsJoinedProvider);
                      }),
                  child: SuperListView.builder(
                    padding: EdgeInsets.only(bottom: 96),
                    itemCount:
                        items
                            .where(
                              (item) =>
                                  selectedTab.value == 0 ||
                                  (selectedTab.value == 1 && item.type == 1) ||
                                  (selectedTab.value == 2 && item.type != 1),
                            )
                            .length,
                    itemBuilder: (context, index) {
                      final filteredItems =
                          items
                              .where(
                                (item) =>
                                    selectedTab.value == 0 ||
                                    (selectedTab.value == 1 &&
                                        item.type == 1) ||
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
            error:
                (error, stack) => ResponseErrorWidget(
                  error: error,
                  onRetry: () {
                    ref.invalidate(chatroomsJoinedProvider);
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
        ref.invalidate(chatroomsJoinedProvider);
      });

      return () {
        subscription.cancel();
      };
    }, [tabController]);

    useEffect(() {
      // Set FAB type to chat
      final fabMenuNotifier = ref.read(fabMenuTypeProvider.notifier);
      Future(() {
        fabMenuNotifier.state = FabMenuType.chat;
      });
      return () {
        // Clean up: reset FAB type to main
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (fabMenuNotifier.state == FabMenuType.chat) {
            fabMenuNotifier.state = FabMenuType.main;
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

    return AppScaffold(
      extendBody: false, // Prevent conflicts with tabs navigation
      appBar: AppBar(
        title: const Text('chat').tr(),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(
              child: Text(
                'chatTabAll'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
            Tab(
              child: Text(
                'chatTabDirect'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
            Tab(
              child: Text(
                'chatTabGroup'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
          ],
        ),
        actions: [
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
            onPressed: () {
              showModalBottomSheet(
                useRootNavigator: true,
                isScrollControlled: true,
                context: context,
                builder: (context) => const _ChatInvitesSheet(),
              );
            },
          ),
          const Gap(8),
        ],
      ),
      body: ChatListBodyWidget(
        isFloating: false,
        tabController: tabController,
        selectedTab: selectedTab,
      ),
    );
  }
}

@riverpod
Future<SnChatRoom?> chatroom(Ref ref, String? identifier) async {
  if (identifier == null) return null;
  try {
    final client = ref.watch(apiClientProvider);
    final resp = await client.get('/sphere/chat/$identifier');
    return SnChatRoom.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null; // Chat room not found
    }
    rethrow; // Rethrow other errors
  }
}

@riverpod
Future<SnChatMember?> chatroomIdentity(Ref ref, String? identifier) async {
  if (identifier == null) return null;
  try {
    final client = ref.watch(apiClientProvider);
    final resp = await client.get('/sphere/chat/$identifier/members/me');
    return SnChatMember.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null; // Chat member not found
    }
    rethrow; // Rethrow other errors
  }
}

@riverpod
Future<List<SnChatMember>> chatroomInvites(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/chat/invites');
  return resp.data
      .map((e) => SnChatMember.fromJson(e))
      .cast<SnChatMember>()
      .toList();
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
        ref.invalidate(chatroomsJoinedProvider);
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
        data:
            (items) =>
                items.isEmpty
                    ? Center(
                      child:
                          Text(
                            'invitesEmpty',
                            textAlign: TextAlign.center,
                          ).tr(),
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
                              Flexible(
                                child:
                                    Text(
                                      invite.role >= 100
                                          ? 'permissionOwner'
                                          : invite.role >= 50
                                          ? 'permissionModerator'
                                          : 'permissionMember',
                                    ).tr(),
                              ),
                              if (invite.chatRoom!.type == 1)
                                Badge(
                                  label: const Text('directMessage').tr(),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  textColor:
                                      Theme.of(context).colorScheme.onPrimary,
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
