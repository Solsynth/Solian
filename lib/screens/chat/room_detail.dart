import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/chat.dart';
import 'package:island/pods/chat/chat_room.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/widgets/account/account_pfc.dart';
import 'package:island/widgets/account/account_picker.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/screens/chat/chat_form.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/pods/database.dart';
import 'package:island/screens/chat/search_messages.dart';

part 'room_detail.freezed.dart';
part 'room_detail.g.dart';

@riverpod
Future<int> totalMessagesCount(Ref ref, String roomId) async {
  final database = ref.watch(databaseProvider);
  return database.getTotalMessagesForRoom(roomId);
}

class ChatDetailScreen extends HookConsumerWidget {
  final String id;
  const ChatDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(chatRoomProvider(id));
    final roomIdentity = ref.watch(chatRoomIdentityProvider(id));
    final totalMessages = ref.watch(totalMessagesCountProvider(id));

    // Local state for pinned status to provide immediate UI feedback
    final isPinned = useState<bool?>(null);

    // Initialize pinned state from database
    useEffect(() {
      final db = ref.read(databaseProvider);
      (db.select(
        db.chatRooms,
      )..where((r) => r.id.equals(id))).getSingleOrNull().then((room) {
        isPinned.value = room?.isPinned ?? false;
      });
      return null;
    }, [id]);

    const kNotifyLevelText = [
      'chatNotifyLevelAll',
      'chatNotifyLevelMention',
      'chatNotifyLevelNone',
    ];

    void setNotifyLevel(int level) async {
      try {
        final client = ref.watch(apiClientProvider);
        await client.patch(
          '/sphere/chat/$id/members/me/notify',
          data: {'notify_level': level},
        );
        ref.invalidate(chatRoomIdentityProvider(id));
        if (context.mounted) {
          showSnackBar(
            'chatNotifyLevelUpdated'.tr(args: [kNotifyLevelText[level].tr()]),
          );
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void setChatBreak(DateTime until) async {
      try {
        final client = ref.watch(apiClientProvider);
        await client.patch(
          '/sphere/chat/$id/members/me/notify',
          data: {'break_until': until.toUtc().toIso8601String()},
        );
        ref.invalidate(chatRoomIdentityProvider(id));
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void showNotifyLevelBottomSheet(SnChatMember identity) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => SheetScaffold(
          height: 320,
          titleText: 'chatNotifyLevel'.tr(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('chatNotifyLevelAll').tr(),
                subtitle: const Text('chatNotifyLevelDescription').tr(),
                leading: const Icon(Icons.notifications_active),
                selected: identity.notify == 0,
                onTap: () {
                  setNotifyLevel(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('chatNotifyLevelMention').tr(),
                subtitle: const Text('chatNotifyLevelDescription').tr(),
                leading: const Icon(Icons.alternate_email),
                selected: identity.notify == 1,
                onTap: () {
                  setNotifyLevel(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('chatNotifyLevelNone').tr(),
                subtitle: const Text('chatNotifyLevelDescription').tr(),
                leading: const Icon(Icons.notifications_off),
                selected: identity.notify == 2,
                onTap: () {
                  setNotifyLevel(2);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    }

    void showChatBreakDialog() {
      final now = DateTime.now();
      final durationController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('chatBreak').tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('chatBreakDescription').tr(),
              const Gap(16),
              ListTile(
                title: const Text('chatBreakClearButton').tr(),
                subtitle: const Text('chatBreakClear').tr(),
                leading: const Icon(Icons.notifications_active),
                onTap: () {
                  setChatBreak(now);
                  Navigator.pop(context);
                  if (context.mounted) {
                    showSnackBar('chatBreakCleared'.tr());
                  }
                },
              ),
              ListTile(
                title: const Text('chatBreak5m').tr(),
                subtitle: const Text(
                  'chatBreakHour',
                ).tr(args: ['chatBreak5m'.tr()]),
                leading: const Icon(Symbols.circle),
                onTap: () {
                  setChatBreak(now.add(const Duration(minutes: 5)));
                  Navigator.pop(context);
                  if (context.mounted) {
                    showSnackBar('chatBreakSet'.tr(args: ['5m']));
                  }
                },
              ),
              ListTile(
                title: const Text('chatBreak10m').tr(),
                subtitle: const Text(
                  'chatBreakHour',
                ).tr(args: ['chatBreak10m'.tr()]),
                leading: const Icon(Symbols.circle),
                onTap: () {
                  setChatBreak(now.add(const Duration(minutes: 10)));
                  Navigator.pop(context);
                  if (context.mounted) {
                    showSnackBar('chatBreakSet'.tr(args: ['10m']));
                  }
                },
              ),
              ListTile(
                title: const Text('chatBreak15m').tr(),
                subtitle: const Text(
                  'chatBreakHour',
                ).tr(args: ['chatBreak15m'.tr()]),
                leading: const Icon(Symbols.timer_3),
                onTap: () {
                  setChatBreak(now.add(const Duration(minutes: 15)));
                  Navigator.pop(context);
                  if (context.mounted) {
                    showSnackBar('chatBreakSet'.tr(args: ['15m']));
                  }
                },
              ),
              ListTile(
                title: const Text('chatBreak30m').tr(),
                subtitle: const Text(
                  'chatBreakHour',
                ).tr(args: ['chatBreak30m'.tr()]),
                leading: const Icon(Symbols.timer),
                onTap: () {
                  setChatBreak(now.add(const Duration(minutes: 30)));
                  Navigator.pop(context);
                  if (context.mounted) {
                    showSnackBar('chatBreakSet'.tr(args: ['30m']));
                  }
                },
              ),
              const Gap(8),
              TextField(
                controller: durationController,
                decoration: InputDecoration(
                  labelText: 'chatBreakCustomMinutes'.tr(),
                  hintText: 'chatBreakEnterMinutes'.tr(),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      final minutes = int.tryParse(durationController.text);
                      if (minutes != null && minutes > 0) {
                        setChatBreak(now.add(Duration(minutes: minutes)));
                        Navigator.pop(context);
                        if (context.mounted) {
                          showSnackBar(
                            'chatBreakSet'.tr(args: ['${minutes}m']),
                          );
                        }
                      }
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('cancel').tr(),
            ),
          ],
        ),
      );
    }

    const iconShadow = Shadow(
      color: Colors.black54,
      blurRadius: 5.0,
      offset: Offset(1.0, 1.0),
    );

    return AppScaffold(
      body: roomState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('errorGeneric'.tr(args: [error.toString()]))),
        data: (currentRoom) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              leading: PageBackButton(shadows: [iconShadow]),
              flexibleSpace: FlexibleSpaceBar(
                background:
                    (currentRoom!.type == 1 &&
                        currentRoom.background?.id != null)
                    ? CloudImageWidget(fileId: currentRoom.background!.id)
                    : (currentRoom.type == 1 &&
                          currentRoom.members!.length == 1 &&
                          currentRoom
                                  .members!
                                  .first
                                  .account
                                  .profile
                                  .background
                                  ?.id !=
                              null)
                    ? CloudImageWidget(
                        fileId: currentRoom
                            .members!
                            .first
                            .account
                            .profile
                            .background!
                            .id,
                      )
                    : currentRoom.background?.id != null
                    ? CloudImageWidget(
                        fileId: currentRoom.background!.id,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                      ),
                title: Text(
                  (currentRoom.type == 1 && currentRoom.name == null)
                      ? currentRoom.members!
                            .map((e) => e.account.nick)
                            .join(', ')
                      : currentRoom.name!,
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                    shadows: [iconShadow],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.people, shadows: [iconShadow]),
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => _ChatMemberListSheet(roomId: id),
                    );
                  },
                ),
                _ChatRoomActionMenu(id: id, iconShadow: iconShadow),
                const Gap(8),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentRoom.description ?? 'descriptionNone'.tr(),
                    style: const TextStyle(fontSize: 16),
                  ).padding(all: 24),
                  const Divider(height: 1),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pin/Unpin Switch
                      if (isPinned.value != null)
                        SwitchListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 24),
                          secondary: Icon(
                            Symbols.push_pin,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          title: const Text('pinChatRoom').tr(),
                          subtitle: const Text('pinChatRoomDescription').tr(),
                          value: isPinned.value!,
                          onChanged: (value) async {
                            // Update local state immediately for instant UI feedback
                            isPinned.value = value;
                            final db = ref.read(databaseProvider);
                            await db.toggleChatRoomPinned(id);
                            // Re-verify the state from database in case of error
                            final room = await (db.select(
                              db.chatRooms,
                            )..where((r) => r.id.equals(id))).getSingleOrNull();
                            final actualPinned = room?.isPinned ?? false;
                            if (actualPinned != value) {
                              // Revert if database operation failed
                              isPinned.value = actualPinned;
                            }
                            showSnackBar(
                              value
                                  ? 'chatRoomPinned'.tr()
                                  : 'chatRoomUnpinned'.tr(),
                            );
                          },
                        ),
                      roomIdentity.when(
                        data: (identity) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              leading: const Icon(Symbols.notifications),
                              trailing: const Icon(Symbols.chevron_right),
                              title: const Text('chatNotifyLevel').tr(),
                              subtitle: Text(
                                kNotifyLevelText[identity!.notify].tr(),
                              ),
                              onTap: () => showNotifyLevelBottomSheet(identity),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              leading: const Icon(Icons.timer),
                              trailing: const Icon(Symbols.chevron_right),
                              title: const Text('chatBreak').tr(),
                              subtitle:
                                  identity.breakUntil != null &&
                                      identity.breakUntil!.isAfter(
                                        DateTime.now(),
                                      )
                                  ? Text(
                                      DateFormat(
                                        'yyyy-MM-dd HH:mm',
                                      ).format(identity.breakUntil!),
                                    )
                                  : const Text('chatBreakNone').tr(),
                              onTap: () => showChatBreakDialog(),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              leading: const Icon(Icons.search),
                              trailing: const Icon(Symbols.chevron_right),
                              title: const Text('searchMessages').tr(),
                              subtitle: totalMessages.when(
                                data: (count) => Text(
                                  'messagesCount'.tr(args: [count.toString()]),
                                ),
                                loading: () =>
                                    const CircularProgressIndicator(),
                                error: (err, stack) => Text(
                                  'errorGeneric'.tr(args: [err.toString()]),
                                ),
                              ),
                              onTap: () async {
                                final result = await context.pushNamed(
                                  'searchMessages',
                                  pathParameters: {'id': id},
                                );
                                if (result is SearchMessagesResult) {
                                  // Navigate back to room screen with message to jump to
                                  if (context.mounted) {
                                    context.pop(result);
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        error: (_, _) => const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatRoomActionMenu extends HookConsumerWidget {
  final String id;
  final Shadow iconShadow;

  const _ChatRoomActionMenu({required this.id, required this.iconShadow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatIdentity = ref.watch(chatRoomIdentityProvider(id));
    final chatRoom = ref.watch(chatRoomProvider(id));

    final isManagable =
        chatIdentity.value?.accountId == chatRoom.value?.accountId ||
        chatRoom.value?.type == 1;

    return PopupMenuButton(
      icon: Icon(Icons.more_vert, shadows: [iconShadow]),
      itemBuilder: (context) => [
        if (isManagable)
          PopupMenuItem(
            onTap: () {
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                builder: (context) => EditChatScreen(id: id),
              ).then((value) {
                if (value != null) {
                  // Invalidate to refresh room data after edit
                  ref.invalidate(chatMemberListProvider(id));
                }
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const Gap(12),
                const Text('editChatRoom').tr(),
              ],
            ),
          ),
        if (isManagable)
          PopupMenuItem(
            child: Row(
              children: [
                const Icon(Icons.delete, color: Colors.red),
                const Gap(12),
                const Text(
                  'deleteChatRoom',
                  style: TextStyle(color: Colors.red),
                ).tr(),
              ],
            ),
            onTap: () {
              showConfirmAlert(
                'deleteChatRoomHint'.tr(),
                'deleteChatRoom'.tr(),
                isDanger: true,
              ).then((confirm) async {
                if (confirm) {
                  final client = ref.watch(apiClientProvider);
                  await client.delete('/sphere/chat/$id');
                  ref.invalidate(chatRoomJoinedProvider);
                  if (context.mounted) {
                    context.pop();
                  }
                }
              });
            },
          )
        else
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: Theme.of(context).colorScheme.error,
                ),
                const Gap(12),
                Text(
                  'leaveChatRoom',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ).tr(),
              ],
            ),
            onTap: () {
              showConfirmAlert(
                'leaveChatRoomHint'.tr(),
                'leaveChatRoom'.tr(),
              ).then((confirm) async {
                if (confirm) {
                  final client = ref.watch(apiClientProvider);
                  await client.delete('/sphere/chat/$id/members/me');
                  ref.invalidate(chatRoomJoinedProvider);
                  if (context.mounted) {
                    context.pop();
                  }
                }
              });
            },
          ),
      ],
    );
  }
}

@freezed
sealed class ChatRoomMemberState with _$ChatRoomMemberState {
  const factory ChatRoomMemberState({
    required List<SnChatMember> members,
    required bool isLoading,
    required int total,
    String? error,
  }) = _ChatRoomMemberState;
}

final chatMemberListProvider = AsyncNotifierProvider.autoDispose.family(
  ChatMemberListNotifier.new,
);

class ChatMemberListNotifier
    extends AsyncNotifier<PaginationState<SnChatMember>>
    with AsyncPaginationController<SnChatMember> {
  static const pageSize = 20;

  final String arg;
  ChatMemberListNotifier(this.arg);

  @override
  Future<List<SnChatMember>> fetch() async {
    final apiClient = ref.watch(apiClientProvider);
    final response = await apiClient.get(
      '/sphere/chat/$arg/members',
      queryParameters: {
        'offset': fetchedCount.toString(),
        'take': pageSize,
        'withStatus': true,
      },
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final members = response.data
        .map((e) => SnChatMember.fromJson(e))
        .cast<SnChatMember>()
        .toList();

    return members;
  }
}

class _ChatMemberListSheet extends HookConsumerWidget {
  final String roomId;
  const _ChatMemberListSheet({required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(chatMemberListProvider(roomId));
    final memberNotifier = ref.watch(chatMemberListProvider(roomId).notifier);

    final roomIdentity = ref.watch(chatRoomIdentityProvider(roomId));
    final chatRoom = ref.watch(chatRoomProvider(roomId));

    final isManagable =
        chatRoom.value?.accountId == roomIdentity.value?.accountId ||
        chatRoom.value?.type == 1;

    Future<void> invitePerson() async {
      final result = await showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => const AccountPickerSheet(),
      );
      if (result == null) return;
      try {
        final apiClient = ref.watch(apiClientProvider);
        await apiClient.post(
          '/sphere/chat/invites/$roomId',
          data: {'related_user_id': result.id, 'role': 0},
        );
        memberNotifier.refresh();
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, left: 20, right: 16, bottom: 12),
            child: Row(
              children: [
                Text(
                  'members'.plural(memberState.value?.totalCount ?? 0),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Symbols.person_add),
                  onPressed: invitePerson,
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                ),
                IconButton(
                  icon: const Icon(Symbols.refresh),
                  onPressed: () {
                    memberNotifier.refresh();
                  },
                ),
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: PaginationList(
              provider: chatMemberListProvider(roomId),
              notifier: chatMemberListProvider(roomId).notifier,
              itemBuilder: (context, idx, member) {
                return ListTile(
                  contentPadding: EdgeInsets.only(left: 16, right: 12),
                  leading: AccountPfcGestureDetector(
                    uname: member.account.name,
                    child: ProfilePictureWidget(
                      fileId: member.account.profile.picture?.id,
                    ),
                  ),
                  title: Row(
                    spacing: 6,
                    children: [
                      Flexible(child: Text(member.account.nick)),
                      if (member.status != null)
                        AccountStatusLabel(
                          status: member.status!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (member.joinedAt == null)
                        const Icon(Symbols.pending_actions, size: 20),
                    ],
                  ),
                  subtitle: Text("@${member.account.name}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isManagable)
                        IconButton(
                          icon: const Icon(Symbols.delete),
                          onPressed: () {
                            showConfirmAlert(
                              'removeChatMemberHint'.tr(),
                              'removeChatMember'.tr(),
                            ).then((confirm) async {
                              if (confirm != true) return;
                              try {
                                final apiClient = ref.watch(apiClientProvider);
                                await apiClient.delete(
                                  '/sphere/chat/$roomId/members/${member.accountId}',
                                );
                                // Refresh both providers
                                memberNotifier.refresh();
                              } catch (err) {
                                showErrorAlert(err);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
